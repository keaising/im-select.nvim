local M = {}

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

M.setup = function(opts)
	if vim.fn.has("macunix") ~= 1 then
		return
	end

	if vim.fn.executable('im-select') ~= 1 then
		vim.api.nvim_err_writeln([[`im-select` not found!
You can install it at: https://github.com/daipeihust/im-select ]])
		return
	end

	local default_im_select = "com.apple.keylayout.ABC"
	if opts ~= nil and opts.im_select_default_im_select ~= nil then
		default_im_select = opts.im_select_default_im_select
	end

	vim.api.nvim_create_autocmd({ "InsertEnter " }, {
		callback = function()
			local current_select = all_trim(vim.fn.system({ "im-select" }))
			local save = vim.g["im_select_current_im_select"]

			if current_select ~= save then
				vim.fn.system({ "im-select", save })
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertLeave " }, {
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
