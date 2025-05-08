local M = {}

M.setup = function()
  require("cmd").register("Rest", "Rest.nvim Dashboard", {
    open = {
      desc = "Show Rest Dashboard",
      impl = function()
        local content = nil

        local buf_ext = vim.fn.expand("%:e")
        if buf_ext == "rest" then
          local bufnr = vim.api.nvim_get_current_buf()
          content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        end

        require("ui.dashboard").open({
          content = content,
        })
      end,
    },
    close = {
      desc = "Hide Rest Dashboard",
      impl = function()
        require("ui.dashboard").close()
      end,
    },
  })
end

return M
