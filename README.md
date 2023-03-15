# im-select.nvim

Switch Input Method automatically depends on Neovim's edit mode.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua for Neovim, it works charmly!

Current version works for Neovim on:

+ macOS
+ Windows and WSL
+ Fcitx5 on Linux

Other frameworks on Linux's support is welcome!

## 1. Install binary

Please install execute binary `im-select` first

Download URL:  [im-select](https://github.com/daipeihust/im-select)

Note: Putting binary into some path which Neovim can read from, you can detect it in Neovim by:

```
# Windows / WSL
:!which im-select.exe

# macOS
:!which im-select

# Linux
:!which fcitx5-remote
```

## 2. Install plugin

Packer

``` lua
use 'keaising/im-select.nvim'
```

Plug

``` vim
Plug 'keaising/im-select.nvim'
```

## 3. Config

Setup with default value works well enough:

```lua
require('im_select').setup()
```

If you want to change some settings: 

```lua
require('im_select').setup {

	-- IM will be set to `default_im_select` in `normal` mode
	-- For Windows/WSL, default: "1033", aka: English US Keyboard
	-- For macOS, default: "com.apple.keylayout.ABC", aka: US
	-- For Linux, default: "keyboard-us"
	-- You can use `im-select` or `fcitx5-remote -n` to get the IM's name you preferred
	default_im_select  = "com.apple.keylayout.ABC",

	-- Set to 1 if you don't want restore IM status when `InsertEnter`
	disable_auto_restore = 0,

	-- Can be binary's name or binary's full path,
	-- e.g. 'im-select' or '/usr/local/bin/im-select'
	-- For Windows/WSL, default: "im-select.exe"
	-- For macOS, default: "im-select"
	-- For Linux, default: "fcitx5-remote"
	default_command = 'im-select.exe'
}
```

