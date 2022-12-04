# <span><img src='./files/fzf-alfred-icon.png' style='height:48px;'/></span> fzf-alfred-workflow

An [Alfred](https://www.alfredapp.com/) workflow fo fuzzy find files/directories using [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd).

## Features

- ⚡️ **Fuzzy Search**: You can enter search keys that partially match file/directory paths *in any order*. 
- 🧠 **Memorization**: Alfred manages the order of items according to *past usage*.
- 🗂 **Folder Action**: Search directory can be set in user preferences or specified dynamically in a *folder action*.

<img src='./files/fzf-alfred-screenshot.png' style='width:500px;'/>

![screenshot](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/files/screenshot.gif)

## Downloads

Current Version: **1.2.1**

- [⤓ Download Workflow for Alfred 5](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/fzf-alfred-workfow.alfredworkflow)
- [⤓ Download Workflow for Alfred 4](https://github.com/yohasebe/fzf-alfred-workflow/raw/main/fzf-alfred-4-workfow.alfredworkflow)

**Change Log**

- 1.2.1: "Check for-update command has been added
- 1.1.1: File and directory searches can be dynamically set with `-f` and `-d`, respectively (in addition to `^f` and `^d`).
- 1.1.0: Memorize order option (`memorize`) is added and set default to `true`
- 1.0.2: Search path option (`search_path`) is set default to `~` (home directory)
- 1.0.1: User configuration made available for Alfred 5

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

### Check for Update

Type `fzf-check-for-update` and run the workflow. If there is a newer version, click on the "Download" button. The readme/download page on Github will open.

### Setting Up

Set values to the following options in `User Configuration` (Alfred 5) or `Environmental Variables` (Alfred 4):

**NOTE**: It is strongly recommended to set the path to a specific folder to `search_path` for better performance.

| Variable         | Explanation                                                                        |
| ---------------- | ---------------------------------------------------------------------------------- |
| `fzf_path`       | Path to `fzf` command (default: `/opt/homebrew/bin/fzf`)                           |
| `fd_path`        | Path to `fd` command (default: `/opt/homebrew/bin/fd`)                             |
| `num_candidates` | Number of candidate files/directories shown in Alfred (default: 100)               |
| `search_path`    | Directory from which recursive fzf searches are conducted __\*__                   |
| `memorize`       | If checked or set `true`, Alfred will manage the order of items according to usage |

__\*__ Search directory can be also specified dynamically in a [folder action](https://www.alfredapp.com/universal-actions/).

You can check paths to `fzf` and `fd` as follows once these have been installed:

```shell
> which fzf
# When installing on Apple Sillicon Model with homebrew 
#/opt/homebrew/bin/fzf 
# When installing on Intel Model with homebrew 
#/usr/local/bin/fzf 

> which fd
# When installing on Apple Sillicon Model with homebrew 
#/opt/homebrew/bin/fd 
# When installing on Intel Model with homebrew 
#/usr/local/bin/fd
```

## Ways of Invocation

**1. Fallback Search** [recommended]

Setup: Features → Default Results → Setup fallback results → Add Workflow Trigger "FZF Search"

Type in search keys and select "FZF Search"

**2. Folder Action** [recommended]

Setup: Features → Universal Actions → Actions → Check Workflow File Actions

Select a folder in the Finder and enter the search key. The selected folder becomes the search path temporarily overriding the search path specified in user configuration.

**3. Using Keyword**

Type in `fzf` and search keys

**4. Using User-specified Hotkey**

Setup: Features → Workflows → fzf-alfred-workflow → Double click "Hotkey"

Press the hotkey specified and type in search keys

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

Use `^f` or `-f` directive to search files only.

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

Use `^d` or `-d` directive to search directories only.

`fzf metallica puppets ^d`

> /music/**metallica**/master-of-**puppets**/

## Acknowledgments

The icon of this workflow <span><img src='./files/fzf-alfred-icon.png' style='height:24px;'/></span> is used under [Simplified Pixabay License](https://pixabay.com/ja/service/license/)
## Author

Yoichiro Hasebe (<yohasebe@gmail.com>)

## License

The MIT License

## Disclaimer

The author of this software takes no responsibility for any damage that may result from using it. 

