local curl = require("plenary.curl")

local M = {}

---Execute HTTP request asynchronously
---@param request Request The request to execute
---@param on_complete function Callback(response) called on success
---@param on_error function|nil Callback(error_msg) called on error
function M.execute_async(request, on_complete, on_error)
  on_error = on_error or function() end

  -- Validate request
  if not request.method or not request.url then
    on_error("Invalid request: missing method or URL")
    return
  end

  -- Schedule in vim.schedule to avoid blocking
  vim.schedule(function()
    local ok, result = pcall(function()
      return curl.request({
        url = request.url,
        method = request.method,
        headers = request.headers or {},
        body = request.body,
      })
    end)

    if ok then
      -- Parse response
      local response = {
        status = result.status or 0,
        body = result.body or "",
        headers = result.headers or {},
        error = nil,
      }
      on_complete(response)
    else
      on_error(tostring(result))
    end
  end)
end

---Execute HTTP request synchronously (blocking)
---@param request Request The request to execute
---@return Response|nil
function M.execute_sync(request)
  -- Validate request
  if not request.method or not request.url then
    return {
      status = 0,
      body = "",
      headers = {},
      error = "Invalid request: missing method or URL",
    }
  end

  local ok, result = pcall(function()
    return curl.request({
      url = request.url,
      method = request.method,
      headers = request.headers or {},
      body = request.body,
    })
  end)

  if ok then
    return {
      status = result.status or 0,
      body = result.body or "",
      headers = result.headers or {},
      error = nil,
    }
  else
    return {
      status = 0,
      body = "",
      headers = {},
      error = tostring(result),
    }
  end
end

---Apply treesitter syntax highlighting to a buffer
---@param bufnr number Buffer number
---@param filetype string Filetype for highlighting
local function apply_syntax_highlighting(bufnr, filetype)
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

---Format response for display
---@param response Response
---@param bufnr number|nil Buffer number for syntax highlighting
---@return string[] Formatted lines
function M.format_response(response, bufnr)
  local lines = {}

  -- Status line
  if response.error then
    table.insert(lines, "ERROR: " .. response.error)
    return lines
  end

  -- Status
  table.insert(lines, "Status: " .. tostring(response.status))
  table.insert(lines, "")

  -- Headers
  if response.headers and vim.tbl_count(response.headers) > 0 then
    table.insert(lines, "Headers:")
    for key, value in pairs(response.headers) do
      table.insert(lines, "  " .. key .. ": " .. tostring(value))
    end
    table.insert(lines, "")
  end

  -- Body
  if response.body and response.body ~= "" then
    -- Try to parse as JSON
    if string.match(response.body, "^{.*}$") or string.match(response.body, "^%[.*%]$") then
      local ok, data = pcall(function()
        return vim.json.decode(response.body)
      end)
      if ok then
        local formatted = vim.json.encode(data)
        for line in vim.gsplit(formatted, "\n") do
          table.insert(lines, line)
        end
        -- Apply JSON syntax highlighting
        if bufnr then
          apply_syntax_highlighting(bufnr, "json")
        end
      else
        -- Invalid JSON, just show raw
        for line in vim.gsplit(response.body, "\n") do
          table.insert(lines, line)
        end
      end
    else
      -- Not JSON, show as text
      for line in vim.gsplit(response.body, "\n") do
        table.insert(lines, line)
      end
    end
  else
    table.insert(lines, "(empty response)")
  end

  return lines
end

return M
