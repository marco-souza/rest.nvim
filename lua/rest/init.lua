local M = {}

local _defaults = {
  margin = 2,
  width = 120,
  height = 30,
  border = "rounded",
  request_pane_width = "30%",
  response_pane_width = "70%",
}

local _config = vim.tbl_deep_extend("force", {}, _defaults)

---Setup the plugin with options
---@param opts table|nil Configuration options
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", _defaults, opts or {})
  _config = vim.tbl_deep_extend("force", _config, opts)

  require("rest.cmd").setup()
end

---Get current configuration
---@return table
function M.get_config()
  return _config
end

return M
