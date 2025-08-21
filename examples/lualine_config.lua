-- Example configuration for lualine with im-select component

-- Method 1: Basic usage
require('lualine').setup {
    sections = {
        lualine_c = { 
            'filename',
            require('im_select.lualine').get_component()
        },
    }
}

-- Method 2: With custom configuration
require('lualine').setup {
    sections = {
        lualine_x = { 
            'encoding', 
            'fileformat', 
            'filetype',
            require('im_select.lualine').get_component({
                -- Custom display names
                display_names = {
                    ["com.apple.keylayout.ABC"] = "🇺🇸 EN",
                    ["com.apple.inputmethod.VietnameseIM.VietnameseSimpleTelex"] = "🇻🇳 VI",
                    ["com.apple.inputmethod.Chinese.Pinyin"] = "🇨🇳 CN",
                },
                
                -- Colors
                color_english = { fg = "#98be65", gui = "bold" },
                color_other = { fg = "#ECBE7B", gui = "bold" },
                
                -- Icon settings
                icon = "⌨️",
                show_icon = true,
                
                -- Update frequency (ms)
                update_interval = 200,
            })
        },
    }
}

-- Method 3: Separate setup then use
require('im_select.lualine').setup({
    display_names = {
        ["com.apple.keylayout.ABC"] = "EN",
        ["com.apple.inputmethod.VietnameseIM.VietnameseSimpleTelex"] = "VI",
    },
    icon = "⌨️",
})

require('lualine').setup {
    sections = {
        lualine_y = { 
            require('im_select.lualine').get_component()
        },
    }
}
