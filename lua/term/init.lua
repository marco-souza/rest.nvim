local M = {}

local dashboard = require("term.ui.dashboard")

local _defaults = {
  margin = 2,
}

---@param opts TermOptions
local function setup(opts)
  opts = vim.tbl_deep_extend("force", _defaults, opts or {})
  require("term.cmd").setup(opts)
end

---@param opts TermOptions
local function toggle(opts)
  opts = vim.tbl_deep_extend("force", _defaults, opts or {})
  dashboard.toggle(opts)
end

M.setup = setup
M.toggle = toggle

return M
