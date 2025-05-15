local curl = require("plenary.curl")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local parse_rest_file = require("utils.rest_parser").parse_rest_file

local popup_one, popup_two =
  Popup({
    enter = true,
    border = "single",
  }), Popup({
    border = "double",
  })

local layout = Layout(
  {
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
  },
  Layout.Box({
    Layout.Box(popup_one, { size = "40%" }),
    Layout.Box(popup_two, { size = "60%" }),
  }, { dir = "row" })
)

local current_dir = "row"
local function toggle_layout()
  if current_dir == "col" then
    layout:update(Layout.Box({
      Layout.Box(popup_one, { size = "40%" }),
      Layout.Box(popup_two, { size = "60%" }),
    }, { dir = "row" }))

    current_dir = "row"
  else
    layout:update(Layout.Box({
      Layout.Box(popup_one, { size = "40%" }),
      Layout.Box(popup_two, { size = "60%" }),
    }, { dir = "col" }))

    current_dir = "col"
  end
end

local function unmount()
  layout:unmount()
end

---@param request ParsedRequest
---@return function
local function feth_to_ui(request)
  return function()
    local res = curl.request({
      url = request.url,
      method = request.method,
      headers = request.headers,
      body = request.body,
    })

    local output

    if string.match(res.body, "^{.*}$") then -- json
      local data = vim.json.decode(res.body)
      local json = vim.inspect(data, { indent = "  ", newline = "\n" })

      output = vim.split(json, "\n")
    elseif #res.body == 0 then -- empty text
      output = { "No content, hit <C-s> to fetch again" }
    else -- text
      output = vim.split(res.body, "\n")
    end

    vim.api.nvim_buf_set_lines(popup_two.bufnr, 0, -1, false, output)
  end
end

local function load_response()
  local req_content =
    vim.fn.join(vim.api.nvim_buf_get_lines(popup_one.bufnr, 0, -1, false), "\n")

  local request = parse_rest_file(req_content)
  if not request then
    vim.api.nvim_buf_set_lines(
      popup_two.bufnr,
      0,
      -1,
      false,
      { "No request found, hit <C-s> to fetch again" }
    )
    return
  end

  vim.api.nvim_buf_set_lines(popup_two.bufnr, 0, -1, false, { "loading..." })

  vim.schedule(feth_to_ui(request))
end

local function yank_response()
  local content = vim.api.nvim_buf_get_lines(popup_two.bufnr, 0, -1, false)
  local text = vim.fn.join(content, "\n")

  vim.fn.setreg("+", text)
  vim.notify("Yanked to clipboard")
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

---@class OpenOptions
---@field content string[]|nil

return {
  ---@param opts OpenOptions|nil
  open = function(opts)
    layout:mount()

    opts = opts or {}

    -- if has content, execute fetch
    if opts.content then
      local request = parse_rest_file(vim.fn.join(opts.content, "\n"))

      if request then
        vim.schedule(feth_to_ui(request))
      end
    end

    -- content to buffer content
    vim.api.nvim_buf_set_lines(
      popup_one.bufnr,
      0,
      -1,
      false,
      opts.content or DEFAULT_REQUEST_CONTENT
    )

    -- set result buffer
    vim.api.nvim_buf_set_lines(
      popup_two.bufnr,
      0,
      -1,
      false,
      { "Hit <C-s> to fetch" }
    )

    popup_one:map("n", "q", unmount, { noremap = true })
    popup_one:map("n", "r", toggle_layout, {})
    popup_one:map("n", "<C-s>", load_response, { noremap = true })
    popup_one:map("n", "<C-y>", yank_response, { noremap = true })
  end,

  close = unmount,
}
