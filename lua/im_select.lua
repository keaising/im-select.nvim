local M = {}

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function determine_os()
	if vim.fn.has("macunix") == 1 then
		return "macOS"
	elseif vim.fn.has("win32") == 1 then
		return "Windows"
	elseif vim.fn.has("unix") == 1 and vim.fn.empty("$WSL_DISTRO_NAME") ~= 1 then
		return "WSL"
	else
		return "Linux"
	end
end

M.setup = function(opts)
	local current_os = determine_os()

	-- Linux is not support yet, PR welcome
	if current_os == "Linux" then
		return
	end

	-- WSL share same config with Windows
	local default_command = "im-select.exe"
	local default_method_selected = "1033"
	if current_os == "macOS" then
		default_command = "im-select"
		default_method_selected = "com.apple.keylayout.ABC"
	end

	if vim.fn.executable(default_command) ~= 1 then
		vim.api.nvim_err_writeln(
			[[please install `im-select` binary first, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end

	-- config
	if opts ~= nil and opts.default_im_select ~= nil then
		default_method_selected = opts.default_im_select
	end

	local auto_restore = true
	if opts ~= nil and opts.disable_auto_restore == 1 then
		auto_restore = false
	end

	-- set autocmd
	if auto_restore then
		vim.api.nvim_create_autocmd({ "InsertEnter" }, {
			callback = function()
				local current_select = all_trim(vim.fn.system({ default_command }))
				local save = vim.g["im_select_current_im_select"]

				if current_select ~= save then
					vim.fn.system({ default_command, save })
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		callback = function()
			local current_select = all_trim(vim.fn.system({ default_command }))
			vim.api.nvim_set_var("im_select_current_im_select", current_select)

			if current_select ~= default_method_selected then
				vim.fn.system({ default_command, default_method_selected })
			end
		end,
	})
end

return M
