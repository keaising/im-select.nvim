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


M.setup = function(opts)
	local current_os = determine_os()

	-- Linux is not support yet, PR welcome
	if current_os == "Linux" then
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
				local current_select = all_trim(vim.fn.system({ C.default_command }))
				local save = vim.g["im_select_current_im_select"]

				if current_select ~= save then
					vim.fn.system({ C.default_command, save })
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter", "CmdlineLeave" }, {
		callback = function()
			local current_select = all_trim(vim.fn.system({ C.default_command }))
			vim.api.nvim_set_var("im_select_current_im_select", current_select)

			if current_select ~= C.default_method_selected then
				vim.fn.system({ C.default_command, C.default_method_selected })
			end
		end,
	})
end

return M
