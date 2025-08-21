-- Lualine component for im-select.nvim
-- Shows input method that will be used in insert mode

local M = {}

-- Config for display
local config = {
    -- Colors
    color_english = { fg = "#98be65" },  -- Green
    color_other = { fg = "#ECBE7B" },    -- Yellow
    -- Icons
    icon = "⌨️",
    show_icon = true,
}

local function get_saved_display_name()
    -- Priority: buffer > window
    return vim.b.im_select_display_name or vim.w.im_select_display_name
end

local function get_color(display_name)
    if not display_name or display_name == "" or display_name == "EN" then
        return config.color_english
    else
        return config.color_other
    end
end

-- Main component function
function M.component()
    return {
        function()
            -- Get the display name that's already computed by im_select
            local display_name = get_saved_display_name()
            
            -- If no context saved, don't show anything
            if not display_name or display_name == "" then
                return ""
            end
            
            if config.show_icon then
                return config.icon .. " " .. display_name
            else
                return display_name
            end
        end,
        
        color = function()
            local display_name = get_saved_display_name()
            return get_color(display_name)
        end,
    }
end

-- Setup function to configure the component
function M.setup(opts)
    if opts then
        config = vim.tbl_deep_extend("force", config, opts)
    end
end

-- Get component for lualine config
function M.get_component(opts)
    if opts then
        M.setup(opts)
    end
    return M.component()
end

return M
