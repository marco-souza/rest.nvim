# Development Guide

## Getting Started

### Prerequisites
- Neovim 0.8+
- nui.nvim
- plenary.nvim

### Project Structure

```
rest.nvim/
├── lua/rest/          # Main plugin source
├── docs/              # Documentation
├── README.md          # User guide
└── REFACTOR.md        # Migration notes
```

## Running Tests

### Quick Validation

```bash
nvim --noplugin -u NONE -N --headless \
  -c "set runtimepath+=$(pwd)" \
  -c "lua require('rest'); print('✅ OK')" \
  -c "qa!"
```

### Full Test Suite

```bash
# Test individual modules
nvim --headless -c "set runtimepath+=$(pwd)" \
  -c "lua require('rest.utils.state'); print('✓')" -c "qa!"

nvim --headless -c "set runtimepath+=$(pwd)" \
  -c "lua require('rest.ui.loader'); print('✓')" -c "qa!"
```

## Code Style

### Lua Conventions

- **Indentation**: 2 spaces
- **Naming**: `snake_case` for functions, `UPPER_CASE` for constants
- **Comments**: Use `---` for documentation comments
- **Type Annotations**: Use Lua comment-based annotations

### Example

```lua
---@class MyClass
---@field name string
---@field value number

local M = {}

---Do something important
---@param input string Input parameter
---@return boolean success
function M.do_something(input)
  -- Implementation
  return true
end

return M
```

## Module Development

### Creating a New Module

1. **Create file** in appropriate directory
2. **Add type annotations** at top
3. **Implement functions** with `---@` comments
4. **Return module table** at end
5. **Test compilation** with validation script

### Example Module

```lua
-- lua/rest/utils/my_module.lua

---@class MyData
---@field key string
---@field value any

local M = {}

---Initialize the module
---@param config table Configuration options
function M.init(config)
  -- Implementation
end

---Process data
---@param data MyData Input data
---@return MyData result
function M.process(data)
  local result = vim.deepcopy(data)
  -- Process...
  return result
end

return M
```

## Integration Points

### Adding to Dashboard

```lua
-- In ui/dashboard.lua
local my_module = require("rest.utils.my_module")

-- Use in functions
function execute_request()
  my_module.init(config)
  local result = my_module.process(data)
end
```

### Adding State

```lua
-- In utils/state.lua
function M.set_custom_data(data)
  local old = custom_data
  custom_data = data
  notify("custom_data", data, old)
end
```

### Adding Commands

```lua
-- In cmd.lua
if args[1] == "custom" then
  -- Handle custom command
end
```

## Debugging

### Print Debugging

```lua
-- Simple print
print("Value:", vim.inspect(value))

-- With context
vim.notify("Debug: " .. tostring(value), vim.log.levels.INFO)
```

### Checking State

```lua
local state = require("rest.utils.state")
print(vim.inspect(state.get_all()))
```

### Buffer Debugging

```lua
-- Check buffer content
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
print("Buffer content:", vim.inspect(lines))
```

## Common Tasks

### Add New HTTP Method Support

1. **Update parser** (`utils/rest_parser.lua`):
```lua
local VALID_METHOD = {
  "GET", "POST", "PUT", "DELETE", "PATCH",
  "OPTIONS", "HEAD", "TRACE", "CONNECT"  -- Add new method
}
```

2. **Update command completion** (`cmd.lua`):
```lua
local VALID_METHODS = { "GET", "POST", ..., "TRACE" }
```

### Add New Configuration Option

1. **Update defaults** (`init.lua`):
```lua
local _defaults = {
  -- ... existing options
  new_option = "default_value",
}
```

2. **Use in components**:
```lua
local config = require("rest").get_config()
if config.new_option then
  -- Use it
end
```

### Add New Keybinding

1. **In dashboard.lua**:
```lua
response_popup:map("n", "<C-n>", function()
  -- Do something
end, { noremap = true })
```

2. **Update README** with keybinding

### Improve Loader Animation

1. **Edit spinner frames** (`ui/loader.lua`):
```lua
local SPINNER_FRAMES = {
  "⠋", "⠙", "⠹", -- ... your frames
}
```

2. **Adjust interval** if needed:
```lua
local SPINNER_INTERVAL = 100  -- milliseconds
```

## Performance Tips

### Async Operations

✅ Good - Non-blocking:
```lua
http_client.execute_async(request, on_complete, on_error)
```

❌ Bad - Blocking:
```lua
local response = http_client.execute_sync(request)
```

### Buffer Updates

✅ Good - Batch updates:
```lua
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, all_lines)
```

❌ Bad - Incremental updates:
```lua
for i, line in ipairs(lines) do
  vim.api.nvim_buf_set_lines(bufnr, i, i, false, {line})
end
```

## Release Checklist

- [ ] Run validation script
- [ ] Test all commands
- [ ] Check backward compatibility
- [ ] Update documentation
- [ ] Update README.md
- [ ] Test with real API
- [ ] Create release notes

## Troubleshooting

### Module Not Loading

```
Error: module 'rest' not found

Solution: Check runtimepath
:echo &runtimepath
```

### Compilation Error

```
Error: Lua chunk: syntax error

Solution: Use `:=` for Lua
:= require("rest")
```

### State Not Updating

```
Solution: Check subscriber callbacks
state.subscribe(function(k, v, o)
  print(k, v, o)
end)
```

## Resources

- [Neovim Lua Guide](https://neovim.io/doc/user/lua.html)
- [nui.nvim Documentation](https://github.com/MunifTanjim/nui.nvim)
- [plenary.nvim Repository](https://github.com/nvim-lua/plenary.nvim)
