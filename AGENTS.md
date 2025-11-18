# AGENTS.md - Commands & Patterns for Amp

This file documents recurring commands and patterns used in this project.

## File Structure Commands

```bash
# View directory structure
tree -I '.git|node_modules|.local' -L 3

# List Lua files in project
find lua -name "*.lua" -type f | sort

# Find all .rest test files
find collections -name "*.rest" -type f
```

## Testing & Running

```bash
# Run Neovim headless with timeout (prevents hanging)
timeout 5 nvim --headless -c "edit <file>" -c "<command>" +qa

# Example: Test `:Rest` command
timeout 5 nvim --headless -c "edit collections/eol.rest" -c "Rest" +qa

# Run with specific config
nvim -u NONE -c "set rtp+=$(pwd)" -c "Rest" <file>
```

## Code Navigation

```bash
# Find function definitions
grep -r "^local function\|^function M\." lua/ --include="*.lua"

# Find all require statements
grep -r "require(" lua/ --include="*.lua" | grep -v "^Binary"

# Find specific pattern (e.g., treesitter calls)
grep -r "treesitter\|apply_syntax" lua/ --include="*.lua"
```

## Git Workflow

```bash
# Check modified files only (no staged)
git status

# View changes in specific files
git diff lua/rest/ui/dashboard.lua

# Stage changes
git add lua/rest/ui/dashboard.lua

# Commit with message
git commit -m "feat: add treesitter syntax highlighting"
```

## Documentation Updates

### Files to Update When Adding Features

1. **README.md** - Add to Features section
2. **docs/FEATURES.md** - Add detailed feature explanation
3. **AGENTS.md** - Add new commands/patterns (this file)

### Example Pattern

When adding a new feature:

1. Implement in Lua code
2. Test with `timeout 5 nvim --headless ...`
3. Update README.md bullets
4. Add detailed docs in docs/FEATURES.md
5. Document new commands in AGENTS.md if applicable

## Key Modules

### `lua/rest/ui/dashboard.lua`
- Main UI interface
- Popup creation and management
- Keyboard mappings
- Layout management

**Key Functions**:
- `M.open(opts)` - Open dashboard
- `M.toggle(opts)` - Toggle dashboard open/close
- `apply_syntax(bufnr, filetype)` - Apply syntax highlighting

### `lua/rest/utils/http_client.lua`
- HTTP request execution
- Response formatting
- Syntax highlighting for responses

**Key Functions**:
- `M.execute_async(request, on_complete, on_error)` - Async HTTP execution
- `M.format_response(response, bufnr)` - Format response with highlighting

### `lua/rest/cmd.lua`
- Command setup
- Direct request execution
- Auto-load from .rest files

**Key Functions**:
- `M.setup()` - Register `:Rest` command
- `get_current_buffer_content()` - Load .rest file content

## Keyboard Shortcuts Reference

All shortcuts are in request panel:

| Shortcut | Action |
|----------|--------|
| `<C-s>` | Execute request |
| `<C-w>` | Toggle word wrap |
| `<C-y>` | Copy response to clipboard |
| `r` | Toggle layout (horizontal/vertical) |
| `q` | Close dashboard |

## Common Development Tasks

### Customize Dashboard Options

```lua
-- In config, pass options to M.open()
local dashboard = require("rest.ui.dashboard")

-- Default: 30% request, 70% response
dashboard.open()

-- Custom proportions: 50% request, 50% response
dashboard.open({
  request_size = "50%",
  response_size = "50%",
  width = "90%",
  height = "90%",
})

-- Fixed sizes
dashboard.open({
  request_size = 40,
  response_size = 120,
})
```

### Add New Keyboard Shortcut

```lua
-- In lua/rest/ui/dashboard.lua M.open() function
request_popup:map("n", "<C-x>", function_name, { noremap = true })
```

### Add Syntax Highlighting to Response

```lua
-- In lua/rest/utils/http_client.lua format_response()
if bufnr then
  apply_syntax_highlighting(bufnr, "filetype_name")
end
```

### Auto-load Feature for New File Types

```lua
-- In lua/rest/cmd.lua get_current_buffer_content()
if filename:match("%.newtype$") then
  local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
  return lines
end
```

## Testing Checklist

- [ ] Feature works in `:Rest` dashboard
- [ ] Feature works with `:Rest GET <url>` direct command
- [ ] Auto-load works for .rest files
- [ ] Syntax highlighting displays correctly
- [ ] No errors on open/close cycles
- [ ] Keyboard shortcuts respond immediately

## Type Definitions

All types are documented in `lua/rest/types.lua`

### Main Types

- `Request` - HTTP request with method, URL, headers, body
- `Response` - HTTP response with status, body, headers, error
- `DashboardOptions` - Configuration for opening dashboard
- `RestConfig` - Global plugin configuration
- `LoaderConfig` - Loading spinner configuration

### Using Types in Development

```lua
-- Type hints in comments
---@param request Request The request to execute
---@return Response|nil
local function execute(request)
  -- implementation
end

-- For optional fields
---@field content string[]|nil Optional pre-loaded content
```

## Version Info

- Lua: 5.1+ (Neovim)
- Neovim: 0.7+
- Dependencies: nui.nvim, plenary.nvim
