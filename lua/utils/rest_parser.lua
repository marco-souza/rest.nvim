local replace_envs = require("utils.env").replace_envs

local M = {}

local VALID_METHOD = {
  "GET",
  "POST",
  "PUT",
  "DELETE",
  "PATCH",
  "OPTIONS",
  "HEAD",
}

local function is_valid_method(method)
  for _, valid_method in ipairs(VALID_METHOD) do
    if method == valid_method then
      return true
    end
  end
  return false
end

local function is_valid_header(header)
  return header ~= nil
    and #header >= 0
    and string.match(header, "^.*{.*$") == nil
    and string.match(header, '^.*".*$') == nil
end

---@class ParsedRequest
---@field method string: The HTTP method (GET, POST, etc.)
---@field url string: The URL for the request
---@field headers table: A table of headers for the request
---@field body string?: The body of the request

--- Parses the content of a REST file into structured requests.
--- @param fileContent string: The content of the REST file as a string.
--- @return ParsedRequest|nil: A table containing parsed requests or nil in case of an error.
function M.parse_rest_file(fileContent)
  -- Ensure the input is a string
  if type(fileContent) ~= "string" then
    error("Invalid input: fileContent must be a string")
    return nil
  end

  local request = {
    headers = {},
    body = nil,
  }

  local lines = vim.split(fileContent, "\n")
  for _, line in ipairs(lines) do
    -- skip if empty line
    line = vim.trim(line)
    if line == "" or string.match(line, "^#+ .*$") then
      goto continue
    end

    -- if method and url not defined, try parse it
    if not request.method and not request.url then
      -- get method and URL
      local method_url_regex = "^(.*) (https?://.+)$"
      local method, url = string.match(line, method_url_regex)

      -- replace URL environment variables
      replace_envs(url)

      -- validate method
      if not is_valid_method(method) then
        error("Invalid method: " .. method)
        return nil
      end

      -- replace URL environment variables
      request.url = replace_envs(url)
      request.method = method

      goto continue
    end

    -- check if it's a header line
    local header_regex = "^(.*): (.*)$"
    local key, value = string.match(line, header_regex)
    if is_valid_header(key) then
      -- replace headers environment variables
      request.headers[key] = replace_envs(value)

      goto continue
    end

    -- if nothing else, add to body
    if not request.body then
      request.body = line
    else
      request.body = request.body .. "\n" .. line
    end

    ::continue::
  end

  -- replace body environment variables
  request.body = replace_envs(request.body)

  return request
end

return M
