local curl = require("plenary.curl")
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local terminal = Popup({ enter = true, border = "rounded" })

local dashboard = Layout(
  {
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
  },
  Layout.Box({
    -- Layout.Box(tabs_sidebar, { size = "20%" }),
    Layout.Box(terminal, { size = "100%" }),
  }, { dir = "row" })
)

local terminal_list = {}

local function add_terminal(cmd)
  table.insert(terminal_list, cmd)

  -- run terminal cmd to terminal popup
  vim.fn.termopen(cmd, {
    on_exit = function(_, _, _)
      -- remove terminal from list
      for i, v in ipairs(terminal_list) do
        if v == cmd then
          table.remove(terminal_list, i)
          break
        end
      end

      -- if no terminal left, close popup
      if #terminal_list == 0 then
        dashboard:unmount()
      end
    end,
  })
end

---@class OpenOptions
---@field content string[]|nil
return {
  ---@param opts OpenOptions|nil
  open = function(opts)
    opts = opts or {}

    dashboard:mount()

    local lines = vim.api.nvim_buf_get_lines(terminal.bufnr, 0, -1, false)
    local mode_info = vim.api.nvim_get_mode()
    local current_mode = mode_info.mode
    print("Current mode:", current_mode)

    if term_mode == "" then
      -- buffer already created
      return
    end

    vim.cmd("terminal")

    terminal:on(event.BufEnter, function(ev) end)

    terminal:on(event.BufLeave, function()
      dashboard:unmount()
    end)

    -- content to buffer content
    terminal:map("t", "<C-q>", function()
      dashboard:unmount()
    end, {})
  end,

  close = function()
    dashboard:unmount()
  end,
}
