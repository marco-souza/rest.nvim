local dashboard = require("rest.ui.dashboard")
local http_client = require("rest.utils.http_client")
local state = require("rest.utils.state")

local M = {}

local VALID_METHODS = { "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD" }

---Check if a string is a valid HTTP method
---@param method string
---@return boolean
local function is_valid_method(method)
  for _, valid in ipairs(VALID_METHODS) do
    if method == valid then
      return true
    end
  end
  return false
end

---Check if arguments look like a direct request (METHOD URL)
---@param args string[]
---@return boolean, string, string|nil
local function parse_direct_request(args)
  if #args < 2 then
    return false, "", nil
  end

  local method = args[1]:upper()
  local url = args[2]

  if is_valid_method(method) and (url:match("^https?://") or url:match("^localhost")) then
    return true, method, url
  end

  return false, "", nil
end

---Extract headers from arguments (format: -H "Key: Value")
---@param args string[]
---@param start_idx number Start checking from this index
---@return table<string, string>
local function extract_headers(args, start_idx)
  local headers = {}
  for i = start_idx, #args - 1 do
    if args[i] == "-H" and i < #args then
      local header = args[i + 1]
      local key, value = header:match("^([^:]+):%s*(.*)$")
      if key and value then
        headers[key] = value
      end
    end
  end
  return headers
end

---Execute a direct HTTP request
---@param method string
---@param url string
---@param body string|nil
---@param headers table<string, string>|nil
local function execute_direct_request(method, url, body, headers)
  local request = {
    method = method,
    url = url,
    headers = headers or {},
    body = body,
  }

  state.set_request(request)
  state.set_loading(true)
  state.set_error(nil)

  -- Show a notification that we're executing
  vim.notify("Executing " .. method .. " " .. url, vim.log.levels.INFO)

  -- Execute async and show result in a floating window or message
  http_client.execute_async(
    request,
    function(response)
      state.set_loading(false)
      state.set_response(response)

      -- Create a simple result window
      local bufnr = vim.api.nvim_create_buf(false, true)
      
      -- Format response for display with syntax highlighting
      local lines = http_client.format_response(response, bufnr)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

      -- Display in a floating window
      local width = math.min(120, vim.o.columns - 4)
      local height = math.min(30, vim.o.lines - 4)
      
      vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
      })

      -- Add quit keybind
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, noremap = true })
    end,
    function(error_msg)
      state.set_loading(false)
      state.set_error(error_msg)
      vim.notify("Error: " .. error_msg, vim.log.levels.ERROR)
    end
  )
end

---Get content from current buffer if it's a .rest file
local function get_current_buffer_content()
  local current_buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(current_buf)
  
  -- Check if current buffer is a .rest file
  if filename:match("%.rest$") then
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    return lines
  end
  
  return nil
end

---Setup the Rest command
function M.setup()
  vim.api.nvim_create_user_command("Rest", function(cmd_opts)
    local args = cmd_opts.fargs
    
    -- No arguments: open dashboard
    if #args == 0 then
      local content = get_current_buffer_content()
      dashboard.toggle({ content = content })
      return
    end

    -- Check if it's a direct request (METHOD URL ...)
    local is_direct, method, url = parse_direct_request(args)
    
    if is_direct then
      -- Extract headers if present
      local headers = extract_headers(args, 3)
      
      -- For POST/PUT/PATCH, check for body
      local body = nil
      if method ~= "GET" and method ~= "DELETE" and method ~= "HEAD" and method ~= "OPTIONS" then
        -- Try to find body argument after headers
        -- For now, we'll just use empty body for direct execution
        -- User can edit in dashboard if they need body
        vim.notify(
          "For " .. method .. " with body, use :Rest to open dashboard",
          vim.log.levels.WARN
        )
      end

      execute_direct_request(method, url, body, headers)
    else
      -- Not a direct request, open dashboard with first arg as potential content
      -- This allows: :Rest to toggle, or :Rest <filename> to load file
      dashboard.toggle()
    end
  end, {
    nargs = "*",
    complete = function(arg_lead, cmdline, _)
      -- Suggest HTTP methods at first arg
      if cmdline:match("^:Rest%s+$") then
        return VALID_METHODS
      end
      return {}
    end,
  })
end

return M
