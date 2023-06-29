local M = {}

local function all_trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function determine_os()
    if vim.fn.has("macunix") == 1 then
        return "macOS"
    elseif vim.fn.has("win32") == 1 then
        return "Windows"
    elseif vim.fn.has("wsl") == 1 then
        return "WSL"
    else
        return "Linux"
    end
end

local function is_supported()
    local os = determine_os()
    -- macOS, Windows, WSL
    if os ~= "Linux" then
        return true
    end

    -- only support fcitx5, fcitx and ibus
    -- other frameworks are not support yet, PR welcome
    if vim.fn.executable("fcitx5-remote") or vim.fn.executable("fcitx-remote") or vim.fn.executable("ibus") then
        return true
    end
end

-- local config
local C = {
    -- im-select binary's name, or the binary's full path
    default_command = "im-select.exe",
    -- default input method in normal mode.
    default_method_selected = "1033",

    -- Restore the default input method state when the following events are triggered
    set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
    -- Restore the previous used input method state when the following events are triggered
    set_previous_events = { "InsertEnter" },

    keep_quiet_on_no_binary = false,
}

local function set_default_config()
    local current_os = determine_os()
    if current_os == "macOS" then
        C.default_command = "im-select"
        C.default_method_selected = "com.apple.keylayout.ABC"
    elseif current_os == "Windows" or current_os == "WSL" then
        -- WSL share same config with Windows
        C.default_command = "im-select.exe"
        C.default_method_selected = "1033"
    else
        -- 0 for close, 1 for inactive, 2 for active
        C.default_command = "fcitx-remote"
        C.default_method_selected = "1"
        if vim.fn.executable("fcitx5-remote") == 1 then
            -- fcitx5-remote -n: rime/keyboard-us
            -- fcitx5-remote -s rime
            -- fcitx5-remote -s keyboard-us
            C.default_command = "fcitx5-remote"
            C.default_method_selected = "keyboard-us"
        elseif vim.fn.executable("ibus") == 1 then
            -- ibus engine xkb:us::eng
            -- ibus engine rime
            C.default_command = "ibus"
            C.default_method_selected = "xkb:us::eng"
        end
    end
end

local function set_opts(opts)
    if opts == nil or type(opts) ~= "table" then
        return
    end

    if opts.default_im_select ~= nil then
        C.default_method_selected = opts.default_im_select
    end

    if opts.default_command ~= nil then
        C.default_command = opts.default_command
    end

    if opts.set_default_events ~= nil and type(opts.set_default_events) == "table" then
        C.set_default_events = opts.set_default_events
    end

    if opts.set_previous_events ~= nil and type(opts.set_previous_events) == "table" then
        C.set_previous_events = opts.set_previous_events
    end

    -- deprecated
    if opts.disable_auto_restore == 1 then
        print("[im-select]: `disable_auto_restore` is deprecated, use `set_previous_events` instead")
        C.set_previous_events = {}
    end

    if opts.keep_quiet_on_no_binary then
        C.keep_quiet_on_no_binary = true
    end
end

local function get_current_select(cmd)
    -- fcitx5 has its own parameters
    if cmd:find("fcitx5-remote", 1, true) ~= nil then
        return all_trim(vim.fn.system({ cmd, "-n" }))
    elseif cmd:find("ibus", 1, true) ~= nil then
        return all_trim(vim.fn.system({ cmd, "engine" }))
    else
        return all_trim(vim.fn.system({ cmd }))
    end
end

local function change_im_select(cmd, method)
    local command = {}
    if cmd:find("fcitx5-remote", 1, true) then
        command = { cmd, "-s", method }
    elseif cmd:find("fcitx-remote", 1, true) then
        -- limited support for fcitx, can only switch for inactive and active
        if method == "1" then
            method = "-c"
        else
            method = "-o"
        end
        command = { cmd, method }
    elseif cmd:find("ibus", 1, true) then
        command = { cmd, "engine", method }
    else
        command = { cmd, method }
    end
    return vim.fn.jobstart(table.concat(command, " "), { detach = true })
end

local function restore_default_im()
    local current = get_current_select(C.default_command)
    vim.api.nvim_set_var("im_select_saved_state", current)

    if current ~= C.default_method_selected then
        change_im_select(C.default_command, C.default_method_selected)
    end
end

local function restore_previous_im()
    local current = get_current_select(C.default_command)
    local saved = vim.g["im_select_saved_state"]

    if current ~= saved then
        change_im_select(C.default_command, saved)
    end
end

M.setup = function(opts)
    if not is_supported() then
        return
    end

    set_default_config()
    set_opts(opts)

    if vim.fn.executable(C.default_command) ~= 1 then
        if not C.keep_quiet_on_no_binary then
            vim.api.nvim_err_writeln(
                [[[im-select]: please install `im-select` binary first, repo url: https://github.com/daipeihust/im-select]]
            )
        end
        return
    end

    -- set autocmd
    local group_id = vim.api.nvim_create_augroup("im-select", { clear = true })

    if #C.set_previous_events > 0 then
        vim.api.nvim_create_autocmd(C.set_previous_events, {
            callback = restore_previous_im,
            group = group_id,
        })
    end

    if #C.set_default_events > 0 then
        vim.api.nvim_create_autocmd(C.set_default_events, {
            callback = restore_default_im,
            group = group_id,
        })
    end
end

return M
