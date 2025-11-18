local Popup = require("nui.popup")
local Layout = require("nui.layout")

local parse_rest_file = require("rest.utils.rest_parser").parse_rest_file
local http_client = require("rest.utils.http_client")
local state = require("rest.utils.state")
local loader = require("rest.ui.loader")

local M = {}

-- Popups will be created fresh for each session
local request_popup = nil
local response_popup = nil

---Apply treesitter syntax highlighting to buffer
local function apply_syntax(bufnr, filetype)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    pcall(function()
      vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
    end)
    pcall(function()
      vim.treesitter.start(bufnr)
    end)
  end)
end

local layout = nil
local current_layout_dir = "row"
local current_request_size = "30%"
local current_response_size = "70%"

---Toggle between row (horizontal) and col (vertical) layout
local function toggle_layout()
   if current_layout_dir == "col" then
     layout:update(Layout.Box({
       Layout.Box(request_popup, { size = current_request_size }),
       Layout.Box(response_popup, { size = current_response_size }),
     }, { dir = "row" }))
     current_layout_dir = "row"
   else
     layout:update(Layout.Box({
       Layout.Box(request_popup, { size = current_request_size }),
       Layout.Box(response_popup, { size = current_response_size }),
     }, { dir = "col" }))
     current_layout_dir = "col"
   end
 end

---Unmount the dashboard
local function unmount_dashboard()
  if layout then
    layout:unmount()
    layout = nil
  end
end

---Format request object into string for display
---@param request Request
---@return string
local function format_request(request)
  local lines = {}
  table.insert(lines, request.method .. " " .. request.url)
  table.insert(lines, "")

  if request.headers and vim.tbl_count(request.headers) > 0 then
    table.insert(lines, "# Headers")
    for key, value in pairs(request.headers) do
      table.insert(lines, key .. ": " .. value)
    end
    table.insert(lines, "")
  end

  if request.body and request.body ~= "" then
    table.insert(lines, "# Body")
    table.insert(lines, request.body)
  end

  return table.concat(lines, "\n")
end

---Parse request from buffer content
---@return Request|nil
local function parse_request_from_buffer()
  local lines = vim.api.nvim_buf_get_lines(request_popup.bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  if content == "" then
    return nil
  end

  local request = parse_rest_file(content)
  return request
end

---Execute the current request
local function execute_request()
  local request = parse_request_from_buffer()
  
  if not request then
    vim.api.nvim_buf_set_lines(
      response_popup.bufnr,
      0,
      -1,
      false,
      { "Error: Invalid request format" }
    )
    return
  end

  -- Show loader
  loader.show(response_popup.bufnr)
  state.set_loading(true)
  state.set_request(request)

  -- Execute async
  http_client.execute_async(
    request,
    -- On complete
    function(response)
      state.set_loading(false)
      loader.hide()
      state.set_response(response)

      -- Format and display response with syntax highlighting
      local formatted = http_client.format_response(response, response_popup.bufnr)
      vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, formatted)
    end,
    -- On error
    function(error_msg)
      state.set_loading(false)
      loader.hide()
      state.set_error(error_msg)
      vim.api.nvim_buf_set_lines(
        response_popup.bufnr,
        0,
        -1,
        false,
        { "ERROR: " .. error_msg }
      )
    end
  )
end

---Yank response to clipboard
local function yank_response()
  local content = vim.api.nvim_buf_get_lines(response_popup.bufnr, 0, -1, false)
  local text = table.concat(content, "\n")

  vim.fn.setreg("+", text)
  vim.notify("Response yanked to clipboard", vim.log.levels.INFO)
end

---Toggle word wrap in response buffer
local function toggle_wrap()
  local winid = response_popup.winid
  if vim.api.nvim_win_is_valid(winid) then
    local wrap = vim.api.nvim_win_get_option(winid, "wrap")
    vim.api.nvim_win_set_option(winid, "wrap", not wrap)
    local status = not wrap and "enabled" or "disabled"
    vim.notify("Word wrap " .. status, vim.log.levels.INFO)
  end
end

---Copy response to clipboard
local function copy_response()
  yank_response()
end

local DEFAULT_REQUEST_CONTENT = {
  "GET https://postman-echo.com/get",
  "",
  "# headers",
  "Accept: application/json",
  "Content-Type: application/json",
  "",
  "# body",
  '# {"key": "value"}',
}

---@class DashboardOptions
---@field margin number|nil Margin around dashboard (default: 0)
---@field width number|string|nil Dashboard width (default: "80%")
---@field height number|string|nil Dashboard height (default: "80%")
---@field border string|nil Border style (default: "single" for request, "double" for response)
---@field content string[]|nil Pre-loaded request content
---@field request_size string|number|nil Request pane size (default: "30%")
---@field response_size string|number|nil Response pane size (default: "70%")

---Open the dashboard
---@param opts DashboardOptions|nil
function M.open(opts)
  opts = opts or {}

  -- Store sizes for toggle_layout to use
  current_request_size = opts.request_size or "30%"
  current_response_size = opts.response_size or "70%"

  -- Create fresh popups
  request_popup = Popup({
    enter = true,
    border = "single",
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  response_popup = Popup({
    border = "double",
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  -- Create layout with configurable sizes
  layout = Layout(
    {
      position = "50%",
      size = {
        width = opts.width or "80%",
        height = opts.height or "80%",
      },
    },
    Layout.Box({
      Layout.Box(request_popup, { size = current_request_size }),
      Layout.Box(response_popup, { size = current_response_size }),
    }, { dir = "row" })
  )

  layout:mount()

  -- Set initial content
  local content = opts.content or DEFAULT_REQUEST_CONTENT
  vim.api.nvim_buf_set_lines(request_popup.bufnr, 0, -1, false, content)
  apply_syntax(request_popup.bufnr, "bash")

  -- Set response buffer initial text
  vim.api.nvim_buf_set_lines(
    response_popup.bufnr,
    0,
    -1,
    false,
    { "Hit <C-s> to fetch" }
  )
  apply_syntax(response_popup.bufnr, "json")

  -- Map keys on request popup only
  request_popup:map("n", "q", unmount_dashboard, { noremap = true })
  request_popup:map("n", "r", toggle_layout, { noremap = true })
  request_popup:map("n", "<C-s>", execute_request, { noremap = true })
  request_popup:map("n", "<C-w>", toggle_wrap, { noremap = true })
  request_popup:map("n", "<C-y>", copy_response, { noremap = true })

  -- Auto-focus request pane
  if vim.api.nvim_win_is_valid(request_popup.winid) then
    vim.api.nvim_set_current_win(request_popup.winid)
  end
end

---Close the dashboard
function M.close()
  unmount_dashboard()
end

---Toggle dashboard (open if closed, close if open)
---@param opts DashboardOptions|nil
function M.toggle(opts)
  if layout and vim.api.nvim_get_current_buf() then
    -- Check if we're in one of the popup buffers
    local current = vim.api.nvim_get_current_buf()
    if current == request_popup.bufnr or current == response_popup.bufnr then
      M.close()
      return
    end
  end
  M.open(opts)
end

return M
