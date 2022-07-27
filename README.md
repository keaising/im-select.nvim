# im-select.nvim

Switch Input Method automatically depends on Neovim's edit mode.

Only works for macOS and Neovim.

The old vim plugins (such as [im-select](https://github.com/daipeihust/im-select)) works weird on my Macbook, so I just create this im-select in pure lua, it works charmly!

## 1. Install binary `im-select`

Go to [im-select](https://github.com/daipeihust/im-select) to install execute binary `im-select`

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
require('im-select').setup()
```

Set your default Input Method, if not set, defalut `com.apple.keylayout.ABC`

```lua
require('im-select').setup {
	default_im_select  = "com.apple.keylayout.ABC",
}
```

