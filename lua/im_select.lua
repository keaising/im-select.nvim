local M = {}

-- FFI backend for Windows (nil means use command-based approach)
local backend = nil

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

local OS_CONFIGS = {
    macOS = { command = { "macism" }, im = "com.apple.keylayout.ABC" },
    Windows = { command = { "im-select.exe" }, im = "1033" },
    WSL = { command = { "im-select.exe" }, im = "1033" },
}

local LINUX_FRAMEWORKS = {
    { bin = "fcitx5-remote", command = { "fcitx5-remote" }, im = "keyboard-us" },
    { bin = "ibus", command = { "ibus", "engine" }, im = "xkb:us::eng" },
    { bin = "fcitx-remote", command = { "fcitx-remote" }, im = "1" },
}

local function is_supported()
    local current_os = determine_os()
    if current_os ~= "Linux" then
        return true
    end

    for _, fw in ipairs(LINUX_FRAMEWORKS) do
        if vim.fn.executable(fw.bin) == 1 then
            return true
        end
    end
    return false
end

-- local config
local C = {
    -- im-select binary's name, or the binary's full path
    default_command = { "im-select.exe" },
    -- default input method in normal mode.
    default_method_selected = "1033",

    -- Restore the default input method state when the following events are triggered
    set_default_events = { "InsertLeave", "CmdlineLeave" },
    -- Restore the previous used input method state when the following events are triggered
    set_previous_events = { "InsertEnter" },

    keep_quiet_on_no_binary = false,

    async_switch_im = true,
}

local function set_default_config()
    local current_os = determine_os()
    local os_config = OS_CONFIGS[current_os]
    if os_config then
        C.default_command = os_config.command
        C.default_method_selected = os_config.im
        return
    end

    -- Linux: pick the first available IM framework
    for _, fw in ipairs(LINUX_FRAMEWORKS) do
        if vim.fn.executable(fw.bin) == 1 then
            C.default_command = fw.command
            C.default_method_selected = fw.im
            return
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
        elseif type(opts.default_command) == "table" then
            C.default_command = opts.default_command
        else
            print("[im-select]: wrong config for default_command")
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
    if backend then
        return backend.get()
    end

    local command = cmd
    if cmd[1]:find("fcitx5-remote", 1, true) ~= nil then
        command = { "fcitx5-remote", "-n" }
    end
    return vim.trim(vim.fn.system(command))
end

local function change_im_select(cmd, method)
    if backend then
        backend.set(method)
        return
    end

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

    local done = false
    local handle
    handle, _ = vim.loop.spawn(
        cmd[1],
        { args = args, detach = true },
        vim.schedule_wrap(function(_, _)
            if handle and not handle:is_closing() then
                handle:close()
            end
            done = true
        end)
    )
    if not handle then
        vim.api.nvim_err_writeln([[[im-select]: Failed to spawn process for ]] .. cmd)
    end

    if not C.async_switch_im then
        vim.wait(5000, function()
            return done
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

local function try_ffi_backend(user_specified_im)
    if determine_os() ~= "Windows" then
        return false
    end

    local ok, win_ffi = pcall(require, "windows_ffi")
    if ok and win_ffi.available then
        backend = win_ffi
        if not user_specified_im then
            C.default_method_selected = win_ffi.default_im
        end
        return true
    end
    return false
end

M.setup = function(opts)
    if not is_supported() then
        return
    end

    set_default_config()
    set_opts(opts)

    local user_specified_im = type(opts) == "table" and opts.default_im_select ~= nil
    local using_ffi = try_ffi_backend(user_specified_im)

    if not using_ffi and vim.fn.executable(C.default_command[1]) ~= 1 then
        if not C.keep_quiet_on_no_binary then
            vim.api.nvim_err_writeln([[[im-select]: binary tools missed, please follow installation manual in README]])
        end
        return
    end

    -- set autocmd
    local group_id = vim.api.nvim_create_augroup("im-select", { clear = true })

    if using_ffi then
        backend.init(group_id)
    end

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
