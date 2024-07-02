local M = {}

M.closed = false

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

    -- Support fcitx5, fcitx and ibus in Linux
    -- other frameworks are not support yet, PR welcome
    local ims = { "fcitx5-remote", "fcitx-remote", "ibus" }
    for _, im in ipairs(ims) do
        if vim.fn.executable(im) then
            return true
        end
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

    async_switch_im = true,
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
            C.default_command = { "ibus", "engine" }
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
        if type(opts.default_command) == "string" then
            C.default_command = { opts.default_command }
        else
            C.default_command = opts.default_command
        end
    else
        if type(C.default_command) == "string" then
            C.default_command = { C.default_command }
        end
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

    if opts.async_switch_im ~= nil and opts.async_switch_im == false then
        C.async_switch_im = false
    end
end

local function get_current_select(cmd)
    local command = cmd
    if cmd[1]:find("fcitx5-remote", 1, true) ~= nil then
        command = { "fcitx5-remote", "-n" }
    end
    return all_trim(vim.fn.system(command))
end

local function change_im_select(cmd, method)
    local args = { unpack(cmd, 2) }

    if cmd[1]:find("fcitx5-remote", 1, true) then
        table.insert(args, "-s")
    elseif cmd[1]:find("fcitx-remote", 1, true) then
        -- limited support for fcitx, can only switch for inactive and active
        if method == "1" then
            method = "-c"
        else
            method = "-o"
        end
    end
    table.insert(args, method)

    local handle
    handle, _ = vim.loop.spawn(
        cmd[1],
        { args = args, detach = true },
        vim.schedule_wrap(function(_, _)
            if handle and not handle:is_closing() then
                handle:close()
            end
            M.closed = true
        end)
    )
    if not handle then
        vim.api.nvim_err_writeln([[[im-select]: Failed to spawn process for ]] .. cmd)
    end

    if not C.async_switch_im then
        vim.wait(5000, function()
            return M.closed
        end, 200)
    end
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

    if vim.fn.executable(C.default_command[1]) ~= 1 then
        if not C.keep_quiet_on_no_binary then
            vim.api.nvim_err_writeln([[[im-select]: binary tools missed, please follow installation manual in README]])
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
