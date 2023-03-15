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

	-- only support fcitx5
	-- other frameworks are not support yet, PR welcome
	if vim.fn.executable("fcitx5-remote") then
		return true
	end
end

-- local config
local C = {
	-- im-select binary's name, or the binary's full path
	default_command = "im-select.exe",
	-- default input method in normal mode.
	default_method_selected = "1033",
	-- auto restore to method to latest used in insert mode when InsertEnter
	auto_restore = true,
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
		-- fcitx5-remote -n: rime/keyboard-us
		-- fcitx5-remote -s rime
		-- fcitx5-remote -s keyboard-us
		C.default_command = "fcitx5-remote"
		C.default_method_selected = "keyboard-us"
	end
end

local function set_opts(opts)
	if opts == nil or type(opts) ~= "table" then
		return
	end

	if opts.default_im_select ~= nil then
		C.default_method_selected = opts.default_im_select
	end

	if opts.disable_auto_restore == 1 then
		C.auto_restore = false
	end

	if opts.default_command ~= nil then
		C.default_command = opts.default_command
	end
end

local function get_current_select(cmd)
	-- fcitx5 has its own parameters
	if cmd:find("fcitx5-remote", 1, true) ~= nil then
		return all_trim(vim.fn.system({ cmd, "-n" }))
	else
		return all_trim(vim.fn.system({ cmd }))
	end
end

local function change_im_select(cmd, method)
	if cmd:find("fcitx5-remote", 1, true) then
		print("change in im-select", cmd, method)
		return vim.fn.system({ cmd, "-s", method })
	else
		return vim.fn.system({ cmd, method })
	end
end

M.setup = function(opts)
	if not is_supported() then
		return
	end

	set_default_config()
	set_opts(opts)

	if vim.fn.executable(C.default_command) ~= 1 then
		vim.api.nvim_err_writeln(
			[[please install `im-select` binary first, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end

	-- set autocmd
	if C.auto_restore then
		vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
			callback = function()
				local current_select = get_current_select(C.default_command)
				local save = vim.g["im_select_current_im_select"]

				if current_select ~= save then
					change_im_select(C.default_command, save)
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter", "CmdlineLeave" }, {
		callback = function()
			local current_select = get_current_select(C.default_command)
			vim.api.nvim_set_var("im_select_current_im_select", current_select)

			if current_select ~= C.default_method_selected then
				change_im_select(C.default_command, C.default_method_selected)
			end
		end,
	})
end

return M
