# im-select.nvim

Switch Input Method automatically depends on NeoVim's edit mode.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua for NeoVim, it works charmingly!

Current version works for NeoVim on:

- macOS
- Windows and WSL
- Fcitx5, ibus on Linux
- Fcitx on Linux(only switch between inactive and active)

Other frameworks on Linux's support is welcome!

## 1. Install binary

For Windows and macOS user, please install executable file `im-select` first

Download URL: [im-select](https://github.com/daipeihust/im-select)

For fcitx5 user, you need to install fcitx5

Note: You need to put the executable file in a path that NeoVim can read from, and then you can find it in NeoVim by doing the following:

```shell
# Windows(NeoVim on Windows use Command Prompt as default shell)
:!where im-select.exe

# WSL
:!which im-select.exe

# macOS
:!which im-select

# Linux
# if you use fcitx5 or fcitx
:!which fcitx5-remote
:!which fcitx-remote
# if you use ibus
:!which ibus
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

Setup is a must, and it works well enough with the default config:

```lua
require('im_select').setup()
```

### Default config

```lua
require('im_select').setup {

    -- IM will be set to `default_im_select` in `normal` mode
    -- For Windows/WSL, default: "1033", aka: English US Keyboard
    -- For macOS, default: "com.apple.keylayout.ABC", aka: US
    -- For Linux, default: "keyboard-us" for Fcitx5 or "1" for Fcitx or "xkb:us::eng" for ibus
    -- You can use `im-select` or `fcitx5-remote -n` to get the IM's name you preferred
    default_im_select  = "com.apple.keylayout.ABC",

    -- Can be binary's name or binary's full path,
    -- e.g. 'im-select' or '/usr/local/bin/im-select'
    -- For Windows/WSL, default: "im-select.exe"
    -- For macOS, default: "im-select"
    -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
    default_command = 'im-select.exe',

    -- Restore the default input method state when the following events are triggered
    set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },

    -- Restore the previous used input method state when the following events are triggered
    -- if you don't want to restore previous used im in Insert mode,
    -- e.g. deprecated `disable_auto_restore = 1`, just let it empty `set_previous_events = {}`
    set_previous_events = { "InsertEnter" },

    -- Show notification about how to install executable binary when binary is missing
    keep_quiet_on_no_binary = false
}
```

### BREAK CHANGE

So sorry for importing a break change

- 2023.05.05: `disable_auto_restore` is deprecated, it can be replaced with more powerful `set_previous_events`, it will be removed in 2023.06
