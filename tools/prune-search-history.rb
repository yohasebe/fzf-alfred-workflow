#!/usr/bin/env ruby
# frozen_string_literal: true

# Removes typing fragments from the search history.
#
# Before version 1.11.0 the script filter recorded the query every time it ran,
# and it runs on every keystroke, so a single search left a trail behind it:
#
#   2024-03-05 09:12:41 | quarterly budget
#   2024-03-05 09:12:40 | quarterly bud
#   2024-03-05 09:12:39 | quarter
#   2024-03-05 09:12:38 | qu
#
# Only the last line is a search anyone made. Version 1.11.0 records once, when a
# result is chosen, so no new trails appear - but the ones already recorded stay
# until something removes them, which is what this script is for. Run it once
# after upgrading.
#
# A line is a fragment when a *nearby* line is one of its prefixes, or it is a
# prefix of one. Nearness matters: "budget" and "budget 2024" ten hours apart are
# two searches that happen to share a prefix, while the same pair one second
# apart is one search being typed. Lines are grouped into bursts of activity and
# the comparison only happens inside a burst, so only the last thing you typed in
# each burst is kept.
#
# Usage:
#   ruby prune-search-history.rb                 # show what would change
#   ruby prune-search-history.rb --apply         # rewrite the file
#   ruby prune-search-history.rb --window 120    # widen a burst to 120 seconds
#   ruby prune-search-history.rb --file PATH     # use a history file elsewhere

require "time"
require "fileutils"

DEFAULT_FILE = File.expand_path(
  "~/Library/Application Support/Alfred/Workflow Data/" \
  "com.yohasebe.fzf-alfred-workflow/fzf-search-history.txt"
)

def parse_args(argv)
  options = { file: DEFAULT_FILE, window: 60, apply: false }
  until argv.empty?
    case (arg = argv.shift)
    when "--apply"  then options[:apply] = true
    when "--file"   then options[:file] = File.expand_path(argv.shift.to_s)
    when "--window" then options[:window] = argv.shift.to_i
    when "-h", "--help"
      puts File.read(__FILE__)[/^# Usage:.*?(?=\n\nrequire)/m].gsub(/^# ?/, "")
      exit 0
    else
      abort "unknown option: #{arg}"
    end
  end
  abort "--window must be a positive number of seconds" unless options[:window].positive?
  options
end

Entry = Struct.new(:line, :time, :search)

def read_entries(path)
  File.readlines(path).map do |line|
    recorded_at, search = line.split("|", 2)
    next if search.nil?
    search = search.strip
    next if search.empty?
    time = begin
      Time.parse(recorded_at.strip)
    rescue ArgumentError, TypeError
      nil
    end
    Entry.new(line, time, search)
  end.compact
end

# Consecutive entries recorded close together belong to the same burst of typing.
# Entries without a usable timestamp start a burst of their own so they are never
# compared against anything.
def bursts(entries, window)
  entries.chunk_while do |a, b|
    !a.time.nil? && !b.time.nil? && (a.time - b.time).abs <= window
  end
end

def prefix_related?(a, b)
  a != b && (a.start_with?(b) || b.start_with?(a))
end

# One or two letters of the Latin alphabet is the beginning of a word, not a
# search. The same is not true of a script that packs a whole word into two
# characters, where a search that short can easily be the most used one in a
# history. So the rule is about script, not length, and it still only applies
# inside a burst.
def too_short_to_be_a_search?(search)
  search.length <= 2 && search.ascii_only?
end

# The file is newest first, so within a burst an entry is a fragment when
# something recorded *later* - earlier in the file - is on the same typing path,
# or when it is too short to have been the search that was meant.
def fragments(burst)
  burst.each_with_index.select do |entry, index|
    next false if index.zero?
    burst[0...index].any? { |newer| prefix_related?(newer.search, entry.search) } ||
      too_short_to_be_a_search?(entry.search)
  end.map(&:first)
end

options = parse_args(ARGV)
abort "no history file at #{options[:file]}" unless File.exist?(options[:file])

entries = read_entries(options[:file])
dropped = bursts(entries, options[:window]).flat_map { |burst| fragments(burst) }
dropped_lines = dropped.map(&:line).each_with_object(Hash.new(0)) { |l, h| h[l] += 1 }

kept = entries.reject { |e| dropped_lines[e.line].positive? && (dropped_lines[e.line] -= 1) }
# Exact repeats of the same search are collapsed to the most recent one.
seen = {}
kept = kept.reject { |e| seen.key?(e.search).tap { seen[e.search] = true } }

puts "history file: #{options[:file]}"
puts "burst window: #{options[:window]}s"
puts
puts "entries:            #{entries.size}"
puts "typing fragments:   #{dropped.size}"
puts "exact repeats:      #{entries.size - dropped.size - kept.size}"
puts "remaining searches: #{kept.size}"

unless dropped.empty?
  puts
  puts "fragments that would be removed (first 40):"
  dropped.first(40).each { |e| puts "  #{e.time&.strftime('%Y-%m-%d %H:%M:%S')} | #{e.search}" }
  puts "  ... and #{dropped.size - 40} more" if dropped.size > 40
end

unless options[:apply]
  puts
  puts "Nothing was changed. Re-run with --apply to rewrite the file."
  exit 0
end

backup = "#{options[:file]}.bak-#{Time.now.strftime('%Y%m%d%H%M%S')}"
FileUtils.cp(options[:file], backup)
File.open(options[:file], "w") { |f| f.puts(kept.map(&:line)) }

puts
puts "rewrote #{options[:file]} (#{kept.size} entries)"
puts "previous contents kept at #{backup}"
