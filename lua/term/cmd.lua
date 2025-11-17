local M = {}

local term = require("term")
local terminal_manager = require("term.utils.terminal")

local _defaults = {
  margin = 2,
}

local _config = vim.tbl_deep_extend("force", {}, _defaults)

---@param opts TermOptions
local function setup(opts)
  opts = vim.tbl_deep_extend("force", _defaults, opts or {})
  _config = vim.tbl_deep_extend("force", _config, opts)

  vim.api.nvim_create_user_command("Term", function(cmd_opts)
    local args = cmd_opts.fargs
    local subcmd = args[1]
    local cmd = table.concat(args, " ", 2)

    if not subcmd then
      -- No args: open dashboard with last active session
      local active = terminal_manager.get_active()
      if not active then
        -- Create new session with shell if none exist
        local shell = vim.env.SHELL or "/bin/bash"
        terminal_manager.create(shell)
      end
      term.toggle({ margin = _config.margin })
    elseif subcmd == "open" then
      -- Open last active session or create new one
      local active = terminal_manager.get_active()
      if not active then
        -- Create new session with shell if none exist
        local shell = vim.env.SHELL or "/bin/bash"
        active = terminal_manager.create(shell)
        vim.notify('Created new terminal: "' .. shell .. '"', vim.log.levels.INFO)
      else
        vim.notify('Opened terminal: "' .. active.cmd .. '"', vim.log.levels.INFO)
      end
      term.toggle({ margin = _config.margin })
    elseif subcmd == "list" then
      -- List all sessions
      local sessions = terminal_manager.list()
      if #sessions == 0 then
        vim.notify("No active terminals", vim.log.levels.INFO)
      else
        local lines = { "Active terminals:" }
        for i, session in ipairs(sessions) do
          table.insert(lines, string.format("  [%d] %s", i, session.cmd))
        end
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
      end
    else
      -- Treat entire input as command to create new terminal
      if cmd == "" then
        cmd = subcmd
      end
      local session = terminal_manager.create(cmd)
      if session then
        vim.notify('Created terminal: "' .. cmd .. '"', vim.log.levels.INFO)
        term.toggle({ margin = _config.margin })
      else
        vim.notify("Failed to create terminal", vim.log.levels.ERROR)
      end
    end
  end, {
    nargs = "*",
    complete = function()
      return { "open", "list" }
    end,
  })
end

M.setup = setup

return M
