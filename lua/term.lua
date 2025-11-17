local M = {}

M.setup = function()
  vim.print("Setting up Term.nvim")
  require("cmd").register("Term", "Term.nvim Dashboard", {
    open = {
      desc = "Show Term Dashboard",
      impl = function()
        require("ui.dashboard").open()
      end,
    },
    close = {
      desc = "Hide Term Dashboard",
      impl = function()
        require("ui.dashboard").close()
      end,
    },
  })
end

return M
