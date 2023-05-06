# im-select.nvim

Switch Input Method automatically depends on NeoVim's edit mode.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua for NeoVim, it works charmingly!

Current version works for NeoVim on:

- macOS
- Windows and WSL
- Fcitx5 on Linux

Other frameworks on Linux's support is welcome!

## 1. Install binary

For Windows and macOS user, please install executable file `im-select` first

Download URL: [im-select](https://github.com/daipeihust/im-select)

For fcitx5 user, you need to install fcitx5

Note: You need to put the executable file in a path that NeoVim can read from, and then you can find it in NeoVim by doing the following:

```
# Windows / WSL
:!which im-select.exe

# macOS
:!which im-select

# Linux
:!which fcitx5-remote
```

## 2. Install plugin

Lazy

```lua
'keaising/im-select.nvim'
```

Packer

```lua
use 'keaising/im-select.nvim'
```

Plug

```vim
Plug 'keaising/im-select.nvim'
```

## 3. Config

### Setup

Setup is a must, and it works well enough with the default settings:

```lua
require('im_select').setup()
```

### Default config

BREAK CHANGE Alert:

I'm sorry to import a break change, `disable_auto_restore` was removed, it can be replaced with more powerful `set_previous_events`

```lua
require('im_select').setup {

    -- IM will be set to `default_im_select` in `normal` mode
    -- For Windows/WSL, default: "1033", aka: English US Keyboard
    -- For macOS, default: "com.apple.keylayout.ABC", aka: US
    -- For Linux, default: "keyboard-us"
    -- You can use `im-select` or `fcitx5-remote -n` to get the IM's name you preferred
    default_im_select  = "com.apple.keylayout.ABC",

    -- Can be binary's name or binary's full path,
    -- e.g. 'im-select' or '/usr/local/bin/im-select'
    -- For Windows/WSL, default: "im-select.exe"
    -- For macOS, default: "im-select"
    -- For Linux, default: "fcitx5-remote"
    default_command = 'im-select.exe'

    -- Restore the default input method state when the following events are triggered
    set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },

    -- Restore the previous used input method state when the following events are triggered
    -- if you don't want to restore previous used im in Insert mode,
    -- e.g. removed `disable_auto_restore = 1`, just let it empty `set_previous_events = {}`
    set_previous_events = { "InsertEnter" },
}
```
