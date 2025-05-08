local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

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

popup_one:map("n", "r", function()
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
end, {})

---@class OpenOptions
---@field content string[]|nil

return {
  ---@param opts OpenOptions|nil
  open = function(opts)
    layout:mount()

    opts = opts or {}

    local content = opts.content
      or {
        "GET https://postman-echo.com/get",
        "",
        "# headers",
        "Accept: application/json",
        "Content-Type: application/json",
        "",
        "# body",
        '# {"key": "value"}',
      }
    vim.api.nvim_buf_set_lines(popup_one.bufnr, 0, -1, false, content)

    popup_one:map("n", "q", function()
      layout:unmount()
    end, { noremap = true })

    vim.api.nvim_buf_set_lines(
      popup_two.bufnr,
      0,
      -1,
      false,
      { "Hit <C-s> to fetch" }
    )
    popup_one:map("n", "<C-s>", function()
      local content = vim.fn.join(
        vim.api.nvim_buf_get_lines(popup_one.bufnr, 0, -1, false),
        "\n"
      )

      local request = require("utils.rest_parser").parse_rest_file(content)

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

      vim.api.nvim_buf_set_lines(
        popup_two.bufnr,
        0,
        -1,
        false,
        { "loading..." }
      )

      vim.schedule(function()
        local curl = require("plenary.curl")
        local res = curl.request({
          url = request.url,
          method = request.method,
          headers = request.headers,
          body = request.body,
        })

        local output = { "No output" }

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
      end)
    end, { noremap = true })
  end,

  close = function()
    layout:unmount()
  end,
}
