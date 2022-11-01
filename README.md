# 🔍 fzf-alfred-workflow

An [Alfred](https://www.alfredapp.com/) workflow fo fuzzy find files/directories using fzf and fd.

*You can search for files and directories by specifying paths and filename fragments in any order.*

![screenshot](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/files/screenshot.gif)

## Downloads

- [fzf-alfred-workflow v0.1.1](https://github.com/yohasebe/fzf-alfred-workflow/releases/download/0.1.1a/fzf-alfred-workfow.alfredworkflow)

## Installation

### Prerequisites

- [Alfred Powerpack](https://www.alfredapp.com/powerpack/)
- [fzf](https://github.com/junegunn/fzf): a general-purpose command-line fuzzy finder
- [fd](https://github.com/sharkdp/fd): a simple, fast and user-friendly alternative to *find*

Installation using [homebrew](https://brew.sh/)

```shell
brew install fzf
brew install fd
```

### Setting Up

Set values to the following variables (use `[x]` button in Alfred's Workflow Setting Panel):

| Variable       | Explanation                                                              |
| -------------- | ------------------------------------------------------------------------ |
|`fd_path`       | Path to `fd` command (default: `/usr/local/bin/fd`)                      |
|`fzf_path`      | Path to `fzf` command (default: `/usr/local/bin/fzf`)                    |
|`num_candidates`| Number of candidate files/directories shown in Alfred (default: 9)       |
|`search_paths`  | Directories from which recursive searches are conducted (`dir1; dir2 ...`)|

You can check paths to `fd` and `fz` as follows once these have been installed:

```shell
> which fd
# /usr/local/bin/fd

> which fzf
# /usr/local/bin/fzf
```

## Example Usage

Suppose you have an mp3 music folder and Metallica's *Master of Puppets* album in it, just for instance.

```
music
└── metallica
    └── master-of-puppets
        ├── 01-battery.mp3
        ├── 02-master-of-puppets.mp3
        ├── 03-the-thing-that-should-not-be.mp3
        ├── 04-welcome-home.mp3
        ├── 05-disposable-heroes.mp3
        ├── 06-leper-messiah.mp3
        ├── 07-orion.mp3
        └── 08-damage-inc.mp3
```

### File/Directory Search

`fzf metallica puppets`

The above will fetch you both files and directories. The order of search keys (`metallica` and `puppets`) does not matter.

> /music/**metallica**/master-of-**puppets**/ \
> /music/**metallica**/master-of-**puppets**/01-battery.mp3 \
> /music/**metallica**/master-of-**puppets**/02-master-of-puppets.mp3 \
> /music/**metallica**/master-of-**puppets**/03-the-thing-that-should-not-be.mp3 \
> /music/**metallica**/master-of-**puppets**/04-welcome-home.mp3 \
> /music/**metallica**/master-of-**puppets**/05-disposable-heroes.mp3 \
> /music/**metallica**/master-of-**puppets**/06-leper-messiah.mp3 \
> /music/**metallica**/master-of-**puppets**/07-orion.mp3 \
> /music/**metallica**/master-of-**puppets**/08-damage-inc.mp3

You can narrow them down by adding search keys. Again, the order of search keys does not matter.

`fzf metallica puppets damage`

> /music/**metallica**/master-of-**puppets**/08-**damage**-inc.mp3

### File Only Search

Use `^f` directive to search files only.

`fzf metallica puppets ^f`

> /music/**metallica**/master-of-**puppets**/01-battery.mp3 \
> /music/**metallica**/master-of-**puppets**/02-master-of-puppets.mp3 \
> /music/**metallica**/master-of-**puppets**/03-the-thing-that-should-not-be.mp3 \
> /music/**metallica**/master-of-**puppets**/04-welcome-home.mp3 \
> /music/**metallica**/master-of-**puppets**/05-disposable-heroes.mp3 \
> /music/**metallica**/master-of-**puppets**/06-leper-messiah.mp3 \
> /music/**metallica**/master-of-**puppets**/07-orion.mp3 \
> /music/**metallica**/master-of-**puppets**/08-damage-inc.mp3

### Directory Only Search

Use `^d` directive to search directories only.

`fzf metallica puppets ^d`

> /music/**metallica**/master-of-**puppets**/

## Ways of Invocation

- Using keyword: `fzf`
- Using hotkey
- Using file action
- Setup fallback search
