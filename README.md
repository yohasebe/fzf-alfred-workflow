# 🔍 fzf-alfred-workflow

<img src='./files/fzf-alfred.png' style='width:500px;'/>

An [Alfred](https://www.alfredapp.com/) workflow fo fuzzy find files/directories using fzf and fd.

![screenshot](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/files/screenshot.gif)

## Downloads

Current Version: `1.0.0`

[⤓ Download Workflow](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/fzf-alfred-workfow.alfredworkflow)

**Change Log**

- `1.0.0`: User Configuration instead of Environment Variables are used

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

Set values to the following options in `User Configuration`:

| Variable       | Explanation                                                          |
| -------------- | ---------------------------------------------------------------------|
|`fzf_path`      | Path to `fzf` command (default: `/opt/homebrew/bin/fzf`)             |
|`fd_path`       | Path to `fd` command (default: `/opt/homebrew/bin/fd`)               |
|`num_candidates`| Number of candidate files/directories shown in Alfred (default: 100) |
|`search_paths`  | Directory from which recursive searches are conducted                |

You can check paths to `fzf` and `fd` as follows once these have been installed:

```shell
> which fzf
#/opt/homebrew/bin/fzf 

> which fd
#/opt/homebrew/bin/fd 
```

## Example Usage

Suppose you have an mp3 music folder and Metallica's *Master of Puppets* album in it, just for instance.

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

## Author

Yoichiro Hasebe (<yohasebe@gmail.com>)

## License

The MIT License

## Disclaimer

The author of this software takes no responsibility for any damage that may result from using it. 

