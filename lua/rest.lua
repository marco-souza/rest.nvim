local M = {}

M.setup = function(opts)
  require("cmd").register("Rest", "Rest.nvim Dashboard", {
    open = {
      desc = "Show Rest Dashboard",
      impl = function(args)
        require("ui.dashboard").open()
      end,
    },
    close = {
      desc = "Hide Rest Dashboard",
      impl = function(args)
        require("ui.dashboard").close()
      end,
    },
  })
end

return M
