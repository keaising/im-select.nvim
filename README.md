# im-select.nvim

Switch Input Method automatically depends on Neovim's edit mode.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua for Neovim, it works charmly!

Current version only works for Neovim on macOS. 

Linux support is welcome!

## 1. Install binary

Please install execute binary `im-select` first!

Download URL:  [im-select](https://github.com/daipeihust/im-select)

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

Simple setup with default value works well enough:

```lua
require('im_select').setup()
```

If you want to change some settings: 

```lua
require('im_select').setup {
	-- IM will be set to `default_im_select` in `normal` mode(`EnterVim` or `InsertLeave`)
	default_im_select  = "com.apple.keylayout.ABC",

	-- Set to 1 if you don't want restore IM status when `InsertEnter`
	disable_auto_restore = 0,
}
```

