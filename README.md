# fzf-alfred-workflow

An Alfred workflow fo fuzzy find files/directories using fzf and fd.

## Downloads

- [fzf-alfred-workflow v0.1](https://github.com/yohasebe/fzf-alfred-workflow/releases/download/0.1/fzf-alfred-workfow.alfredworkflow)

## Installation

### Prerequisites

- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)

Installation using [homebrew](https://brew.sh/)

```shell
brew install fzf
brew install fd
```

### Setting Up

Set values to the following variables (use `[x]` button in Alfred's Workflow Setting Panel):

| Variable       | Explanation                                             |
| -------------- | ------------------------------------------------------- |
|`fd_path`       | Path to `fd` command (default: `/usr/local/bin/fd`)     |
|`fzf_path`      | Path to `fzf` command (default: `/usr/local/bin/fzf`)   |
|`num_candidates`| Number of candidate files/directories shown in Alfred   |
|`search_home`   | Home directory from which recursive search is conducted |

You can check paths to `fd` and `fz` once these have been installed as follows:

```shell
> which fd
# /usr/local/bin/fd

> which fzf
# /usr/local/bin/fzf
```

## Example Usage

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

