local M = {}

local SPINNER_FRAMES = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}

local SPINNER_INTERVAL = 100 -- milliseconds

---@class LoaderState
---@field bufnr number Buffer number for loading indicator
---@field current_frame number Current spinner frame index
---@field timer number|nil Timer ID for animation
---@field is_visible boolean Is loader currently visible

local loader_state = {
  bufnr = nil,
  current_frame = 0,
  timer = nil,
  is_visible = false,
}

---Display loading indicator with animation
---@param bufnr number Buffer to write to
function M.show(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  loader_state.bufnr = bufnr
  loader_state.current_frame = 0
  loader_state.is_visible = true

  local function animate()
    if not loader_state.is_visible or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    loader_state.current_frame = (loader_state.current_frame % #SPINNER_FRAMES) + 1
    local frame = SPINNER_FRAMES[loader_state.current_frame]
    local text = frame .. " Loading..."

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { text })

    loader_state.timer = vim.fn.timer_start(SPINNER_INTERVAL, animate)
  end

  animate()
end

---Hide loading indicator
function M.hide()
  loader_state.is_visible = false

  if loader_state.timer then
    vim.fn.timer_stop(loader_state.timer)
    loader_state.timer = nil
  end

  if loader_state.bufnr and vim.api.nvim_buf_is_valid(loader_state.bufnr) then
    vim.api.nvim_buf_set_lines(loader_state.bufnr, 0, -1, false, {})
  end
end

---Check if loader is currently visible
---@return boolean
function M.is_visible()
  return loader_state.is_visible
end

return M
