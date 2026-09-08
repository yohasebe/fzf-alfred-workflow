#!/usr/bin/env ruby
# frozen_string_literal: true

# Build the distribution bundle from an explicit allowlist.
#
#   ruby scripts/pack_workflow.rb            # check only
#   ruby scripts/pack_workflow.rb --write    # check, then write the bundle
#
# Why not Alfred's GUI export: it puts everything in the workflow directory
# except prefs.plist into the zip. Anything a run leaves behind ships. That is
# how microphone recordings, a log of local file paths, `tags`, and
# `info.plist.bak` reached published bundles across four repositories in
# September 2026. "Look at the folder before exporting" is not a control.
#
# The check runs in BOTH directions, and either one failing stops the build:
#
#   listed but missing  -> we would ship an incomplete workflow
#   present but unknown -> we would ship something nobody decided to ship
#
# One direction is not enough. A sibling workflow shipped 54 files with its
# icon.png deleted and no error, because a workflow without an icon installs
# fine and nothing complained.
#
# Fixed content is listed by name. Only the places where Alfred generates the
# names are matched by pattern: it writes `<object-uid>.png` beside the
# workflow when a node is given an icon, so "every png at the root" would be
# the wrong rule.

require "fileutils"
require "tmpdir"

# The installed workflow folder has to be supplied. It is deliberately not
# defaulted here: the path would say which sync folder its author keeps Alfred's
# preferences in and which installed copy of the workflow is theirs, and neither
# belongs in a public repository. Set it in the shell, or in a gitignored .envrc.
WF = ENV["ALFRED_WORKFLOW_DIR"].to_s
if WF.empty?
  warn <<~USAGE
    ALFRED_WORKFLOW_DIR is not set, and there is no default.

      export ALFRED_WORKFLOW_DIR=".../Alfred.alfredpreferences/workflows/user.workflow.<uid>"
      ruby scripts/pack_workflow.rb [--write]

    To find the folder: right-click the workflow in Alfred and choose
    "Open in Finder".
  USAGE
  exit 2
end
unless File.directory?(WF)
  warn "ALFRED_WORKFLOW_DIR is not a directory: #{WF}"
  exit 2
end

REPO = File.expand_path("..", __dir__)
BUNDLE = File.join(REPO, "fzf-alfred-workfow.alfredworkflow")

# --- the allowlist ----------------------------------------------------------

# Everything this workflow ships that has a fixed name. The search logic lives
# inside info.plist as embedded scripts, so there are no loose script files.
NAMED = %w[info.plist icon.png icon-mini.png].freeze

# Alfred generates these names; they cannot be listed.
GENERATED = [
  /\A[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\.png\z/,
  %r{\AList Filter Images/[^/]+\.png\z}
].freeze

# Deliberately never shipped. Named so that finding one is not a surprise.
EXCLUDED = ["prefs.plist"].freeze

# --- gather -----------------------------------------------------------------

on_disk = Dir.glob("#{WF}/**/*", File::FNM_DOTMATCH)
          .select { |p| File.file?(p) }
          .map { |p| p.sub("#{WF}/", "") }
          .sort

allowed  = on_disk.select { |f| NAMED.include?(f) || GENERATED.any? { |re| f =~ re } }
excluded = on_disk.select { |f| EXCLUDED.include?(f) }
unknown  = on_disk - allowed - excluded
missing  = NAMED - on_disk

puts "workflow folder: #{on_disk.length} files"
puts "  to ship:  #{allowed.length}"
puts "  excluded: #{excluded.length} #{excluded.inspect}"
puts

problems = false

unless missing.empty?
  puts "LISTED BUT MISSING (#{missing.length}) - the bundle would be incomplete:"
  missing.each { |f| puts "  #{f}" }
  puts
  problems = true
end

unless unknown.empty?
  puts "PRESENT BUT UNKNOWN (#{unknown.length}) - nobody decided to ship these:"
  unknown.each { |f| puts "  #{f}" }
  puts "  Either delete them from the workflow folder, or add them to the"
  puts "  allowlist in this script if they genuinely belong in the release."
  puts
  problems = true
end

# A last look inside, independent of the lists above.
suspicious = allowed.select do |f|
  f =~ /\.(log|mp3|wav|m4a|webm|bak|orig|tmp)\z/i || f =~ %r{(\A|/)(tags|\.DS_Store|data\.json)\z}
end
unless suspicious.empty?
  puts "ALLOWLISTED BUT SUSPICIOUS (#{suspicious.length}): #{suspicious.inspect}"
  problems = true
end

TEXTUAL = ->(f) { f !~ /\.(png|woff2|icns)\z/i }

# Alfred's export excludes exactly one name, prefs.plist. That is a denylist of
# length one: a second file holding a key would ship. An allowlist already
# refuses anything unrecognised, but the files we *do* ship are worth reading -
# a key pasted into a script would pass every check above.
SECRETS = /sk-[A-Za-z0-9_-]{16,}|ghp_[A-Za-z0-9]{20,}|github_pat_|BEGIN (RSA |OPENSSH )?PRIVATE KEY|xox[baprs]-/.freeze
leaking = allowed.select { |f| TEXTUAL.call(f) && File.binread(File.join(WF, f)) =~ SECRETS }
unless leaking.empty?
  puts "SECRET-SHAPED STRINGS in files we would ship (#{leaking.length}):"
  leaking.each { |f| puts "  #{f}" }
  problems = true
end

# And the local-environment traces that should not travel either.
traces = allowed.select { |f| TEXTUAL.call(f) && File.binread(File.join(WF, f)) =~ %r{/Users/[a-z]}i }
unless traces.empty?
  puts "ABSOLUTE HOME PATHS in files we would ship (#{traces.length}): #{traces.inspect}"
  problems = true
end

# This workflow is a file search, so the thing most likely to leak from it is
# the user's own past queries: folder names, course names, the names of people.
# They live in the workflow's data directory, and one pasted into a comment
# while debugging would ship.
#
# The terms are read from that file at build time and are never written
# anywhere. They are private search history and must not enter this repository,
# which is why this check cannot be a list of words kept in the script.
# The two scripts are matched differently, because the languages differ in what
# a short string tells you about its author.
#
#   Japanese  whole queries and their individual words, as substrings. The
#             script has no word separator, so a boundary match is meaningless,
#             and a two-character word is already a name or a specific noun.
#
#   ASCII     whole queries only, on word boundaries. An English word out of a
#             query is usually an ordinary word - matching "forms" or "change"
#             as a substring flags this workflow's own English comments, where
#             they sit inside "both forms" and "unchanged". The query as typed
#             is what identifies someone; one common word out of it does not.
def search_terms(workflow_dir)
  plist = File.join(workflow_dir, "info.plist")
  return [nil, nil, "info.plist is missing"] unless File.exist?(plist)

  bundle_id = File.read(plist)[%r{<key>bundleid</key>\s*<string>([^<]+)</string>}m, 1]
  return [nil, nil, "no bundle id in info.plist"] unless bundle_id

  dir = File.expand_path("~/Library/Application Support/Alfred/Workflow Data/#{bundle_id}")
  files = Dir["#{dir}/fzf-search-history.txt*"]
  return [nil, nil, "no search history on this machine"] if files.empty?

  queries = files.flat_map { |f| File.readlines(f) }
                 .map { |l| l.split("|", 2)[1] }.compact.map(&:strip).reject(&:empty?).uniq

  # The workflow's own identity strings are in info.plist by design. Searching
  # for one of them puts it in the history too, and it would then match for the
  # wrong reason, on every build, for ever.
  identity = File.read(plist).scan(%r{<string>([^<]*(?:com\.[a-z0-9.-]+|https?://[^<]+)[^<]*)</string>}i).flatten.join(" ")

  japanese = (queries + queries.flat_map { |q| q.split(/\s+/) }).uniq
             .reject(&:ascii_only?).select { |t| t.length >= 2 }
  ascii = queries.select { |q| q.ascii_only? && q.length >= 6 }.reject { |t| identity.include?(t) }
  [japanese, ascii, nil]
end

japanese, ascii, why_not = search_terms(WF)
if japanese.nil?
  puts "SEARCH-HISTORY CHECK SKIPPED: #{why_not}"
  puts "  Run this on the machine that uses the workflow to get the check."
else
  found = allowed.select do |f|
    next false unless TEXTUAL.call(f)
    body = File.binread(File.join(WF, f))
    japanese.any? { |t| body.include?(t.b) } ||
      ascii.any? { |t| body =~ /\b#{Regexp.escape(t)}\b/i }
  end
  unless found.empty?
    # The matching term is not printed: it is the thing being protected.
    puts "PAST SEARCH QUERIES in files we would ship (#{found.length}): #{found.inspect}"
    puts "  Checked #{japanese.length} + #{ascii.length} terms from this machine's search history."
    problems = true
  end
end

if problems
  puts "Refusing to build."
  exit 1
end

puts "Allowlist agrees with the folder in both directions."

exit 0 unless ARGV.include?("--write")

# --- build ------------------------------------------------------------------

tmp = File.join(Dir.tmpdir, "pack-#{Process.pid}.zip")
File.delete(tmp) if File.exist?(tmp)
# Alfred's own export writes a directory entry for each directory it ships.
# Extractors do not need them, but matching the structure of the artefact
# Alfred produces keeps this bundle from being the odd one out.
dirs = allowed.map { |f| File.dirname(f) }
              .reject { |d| d == "." }
              .flat_map { |d| d.split("/").each_with_object([]) { |part, acc| acc << (acc.empty? ? part : "#{acc.last}/#{part}") } }
              .uniq.sort.map { |d| "#{d}/" }

Dir.chdir(WF) do
  # -X drops extra attributes so the zip is reproducible between machines.
  args = ["zip", "-X", "-q", tmp] + dirs + allowed
  system(*args) or abort "zip failed"
end

# Verify what was actually written, rather than trusting the command.
written = `unzip -Z1 "#{tmp}"`.lines.map(&:chomp).reject(&:empty?).sort
if written != (dirs + allowed).sort
  puts "the zip does not contain what we asked for:"
  puts "  only in zip:    #{(written - dirs - allowed).inspect}"
  puts "  missing in zip: #{((dirs + allowed) - written).inspect}"
  File.delete(tmp)
  exit 1
end

Dir.mktmpdir do |dir|
  system("unzip", "-q", "-o", tmp, "-d", dir, out: File::NULL) or abort "unzip failed"
  differing = allowed.reject do |f|
    File.binread(File.join(WF, f)) == File.binread(File.join(dir, f))
  end
  unless differing.empty?
    puts "content differs from the folder: #{differing.inspect}"
    File.delete(tmp)
    exit 1
  end
end

FileUtils.mv(tmp, BUNDLE)
puts "wrote #{BUNDLE} (#{allowed.length} entries, #{File.size(BUNDLE)} bytes)"
