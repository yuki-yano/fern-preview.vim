# fern-preview.vim

Add a file preview function to [fern.vim](https://github.com/lambdalisue/fern.vim).

## Features

- File preview in popup window or floating window
- Toggle auto preview mode
- Scroll preview window

## Demo

![fern-preview](https://user-images.githubusercontent.com/5423775/120148266-ec0ec680-c222-11eb-9a3f-42ff148708ec.gif "fern-preview")


## Requirements

- [fern.vim](https://github.com/lambdalisue/fern.vim)

## Installation

### vim-plug

```vim
Plug 'lambdalisue/fern.vim'
Plug 'yuki-yano/fern-preview.vim'
```

### dein

```vim
call dein#add('lambdalisue/fern.vim')
call dein#add('yuki-yano/fern-preview.vim')
```

## Usage

### Mapping

```vim
nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
```

### Use smart_preview function example

```vim
nmap <silent> <buffer> <expr> <Plug>(fern-quit-or-close-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:close)", ":q\<CR>")
nmap <silent> <buffer> q <Plug>(fern-quit-or-close-preview)
```
