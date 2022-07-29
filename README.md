# im-select.nvim

Switch Input Method automatically depends on Neovim's edit mode.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua for Neovim, it works charmly!

Current version only works for Neovim on macOS. 

Linux support is welcome!

## 1. Install binary

Please install execute binary `im-select` first! Download URL:  [im-select](https://github.com/daipeihust/im-select)

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

```lua
require('im_select').setup()
```

Set your default Input Method, if not set, defalut `com.apple.keylayout.ABC`

```lua
require('im_select').setup {
	default_im_select  = "com.apple.keylayout.ABC", -- IM will be set to `default_im_select` when `EnterVim` or `InsertLeave`
	disable_auto_restore = 0,                       -- set to 1 if you don't want restore IM status when `InsertEnter`
}
```

