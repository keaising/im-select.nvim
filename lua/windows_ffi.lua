-- Windows IME control via LuaJIT FFI
-- Eliminates the need for external im-select.exe binary on Windows

local M = {}

M.available = false
M.default_im = "0"

local ffi_ok, ffi = pcall(require, "ffi")
if not ffi_ok then
    return M
end

local cdef_ok = pcall(function()
    ffi.cdef([[
        typedef unsigned int UINT, HWND, WPARAM;
        typedef unsigned long LPARAM, LRESULT;
        LRESULT SendMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
        HWND ImmGetDefaultIMEWnd(HWND unnamedParam1);
        HWND GetForegroundWindow();
    ]])
end)
if not cdef_ok then
    return M
end

local user32_ok, user32 = pcall(ffi.load, "user32.dll")
if not user32_ok then
    return M
end

local imm32_ok, imm32 = pcall(ffi.load, "imm32.dll")
if not imm32_ok then
    return M
end

local WM_IME_CONTROL = 0x283
local IMC_GETCONVERSIONMODE = 0x001
local IMC_SETCONVERSIONMODE = 0x002

local ime_hwnd = nil

--- Register an autocmd to lazily capture the IME window handle.
--- Must be called after the foreground window is the Neovim window,
--- so we defer to the first InsertEnter or CmdlineEnter event.
---@param group_id number augroup id
function M.init(group_id)
    vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
        group = group_id,
        once = true,
        desc = "[im-select] capture IME window handle via FFI",
        callback = function()
            ime_hwnd = imm32.ImmGetDefaultIMEWnd(user32.GetForegroundWindow())
        end,
    })
end

---@return string current IME conversion mode as string
function M.get()
    if not ime_hwnd then
        return M.default_im
    end
    return tostring(tonumber(user32.SendMessageA(ime_hwnd, WM_IME_CONTROL, IMC_GETCONVERSIONMODE, 0)))
end

---@param mode string IME conversion mode as string (e.g. "0" for English, "1025" for Chinese)
function M.set(mode)
    if not ime_hwnd then
        return
    end
    user32.SendMessageA(ime_hwnd, WM_IME_CONTROL, IMC_SETCONVERSIONMODE, tonumber(mode))
end

M.available = true

return M
