local M = {}

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

M.setup = function(opts)
	if vim.fn.has("macunix") ~= 1 and vim.fn.has('win32') ~= 1 then
		return
	end

	if vim.fn.executable("im-select") ~= 1 then
		vim.api.nvim_err_writeln(
			[[please install `im-select` first, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end

	-- config
	local default_im_select = "com.apple.keylayout.ABC"
	if vim.fn.has('win32') == 1 then
		default_im_select = '1033'
	end
	if opts ~= nil and opts.default_im_select ~= nil then
		default_im_select = opts.default_im_select
	end

	local auto_restore = true
	if opts ~= nil and opts.disable_auto_restore == 1 then
		auto_restore = false
	end

	-- set autocmd
	if auto_restore then
		vim.api.nvim_create_autocmd({ "InsertEnter" }, {
			callback = function()
				local current_select = all_trim(vim.fn.system({ "im-select" }))
				local save = vim.g["im_select_current_im_select"]

				if current_select ~= save then
					vim.fn.system({ "im-select", save })
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		callback = function()
			local current_select = all_trim(vim.fn.system({ "im-select" }))
			vim.api.nvim_set_var("im_select_current_im_select", current_select)

			if current_select ~= default_im_select then
				vim.fn.system({ "im-select", default_im_select })
			end
		end,
	})
end

return M
