# AGENTS.md - Development Guidelines

## Project Overview

**term.nvim** is a Neovim plugin for managing multiple terminal sessions with an interactive dashboard. The plugin provides a `:Term <cmd>` command interface and displays active terminals in a split-pane layout.

## Architecture

### Directory Structure

```
lua/
├── term/                # Plugin package (matches "term.nvim")
│   ├── init.lua         # Entry point: require("term")
│   ├── cmd.lua          # Command definitions: require("term.cmd")
│   ├── types.lua        # Shared type definitions
│   ├── ui/
│   │   └── dashboard.lua # Dashboard UI: require("term.ui.dashboard")
│   └── utils/
│       └── terminal.lua # Terminal session management (TODO)
└── tests/               # Test files
    └── init.lua         # Test runner
```

### Core Modules

- **cmd.lua**: Registers `:Term` command and routes subcommands
- **dashboard.lua**: Manages UI layout (20% left panel for sessions, 80% right panel for terminal)
- **terminal.lua**: Handles terminal session lifecycle (create, switch, close)
- **env.lua**: Manages environment variables for terminal sessions

## Conventions

### Naming
- Use snake_case for functions and variables
- Use PascalCase for class-like objects
- Prefix private functions with underscore: `_internal_function()`

### Code Style
- Follow `.stylua.toml` formatting rules
- Run `make lint` before committing
- Max line length: 80 characters (stylua enforces this)
- Use 2 spaces for indentation
- Always define default values for function parameters
- Use Lua comments to document types: `---@param name type: description`

### Default Values
- Always provide sensible defaults in `_defaults` table at module level
- Merge user options with defaults using `vim.tbl_deep_extend("force", defaults, opts or {})`
- Example:
  ```lua
  local _defaults = { margin = 2 }
  local function my_function(opts)
    opts = vim.tbl_deep_extend("force", _defaults, opts or {})
    -- opts.margin is guaranteed to exist
  end
  ```

### Type Documentation
- Document function parameters with Lua type comments
- Format: `---@param param_name param_type: description`
- Define shared types in `lua/term/types.lua` to avoid repetition
- Example:
  ```lua
  -- lua/term/types.lua
  ---@class TermOptions
  ---@field margin number: Margin size in characters (default: 2)
  
  -- Usage in other files:
  ---@param opts TermOptions
  local function toggle(opts)
  end
  ```

### File Organization
- Keep UI code in `ui/` directory
- Keep utilities in `utils/` directory
- Keep tests in `tests/` directory matching source structure

## Common Commands

### Development
```bash
make fmt            # Format code with stylua
make lint           # Run luacheck linter
make test           # Run test suite (headless nvim)
make pr-ready       # Format + lint (ready for PR)
```

### Testing
- Run all tests: `make test`
- Tests run in headless Neovim: `nvim --headless -c 'lua require("tests")' -c 'qa!'`
- Add tests in `tests/` directory mirroring source structure
- Use descriptive test names
- Test utilities separately from UI components

### Code Formatting & Linting
- **stylua**: Formats Lua code (80 char width, 2-space indent)
- **luacheck**: Static analysis (allows `vim` global)
- Run `make fmt` before committing
- Max line length: 80 characters (stylua config)

## Plugin Architecture

### Initialization Flow
1. User runs `:Term <cmd>` or `:Term`
2. `cmd.lua` routes to appropriate handler
3. `terminal.lua` manages session state
4. `dashboard.lua` renders UI with nui.nvim

### Dashboard Layout
- **Left Panel (20%)**: Terminal session list
  - Shows all active sessions
  - Highlights current active session
  - Navigation with j/k, selection with Enter
  
- **Right Panel (80%)**: Active terminal display
  - Full terminal emulation
  - Receives keyboard input
  - Shows real-time output

### Terminal Session Lifecycle
1. Create: `:Term <cmd>` spawns new session
2. Switch: Select from left panel
3. Close: Delete key or `:Term close`

**Important**: Sessions persist even after the dashboard is closed. Users can:
- Close dashboard with `q` without terminating sessions
- Reopen dashboard later with `:Term` and see all active sessions
- Sessions continue running in background with their output/state preserved

## Keybindings

### Left Panel (Session List)
- `j/k` - Move up/down
- `<CR>` - Select session
- `d` - Delete session
- `n` - New session

### Right Panel (Terminal)
- All terminal input passes through

### Global
- `<C-l>` - Focus right (terminal)
- `<C-h>` - Focus left (sessions)
- `q` - Close dashboard

## Testing Guidelines

- Create test files in `tests/` mirroring source structure
- Test core functions: session creation, switching, deletion
- Test env variable substitution
- Use descriptive assertion messages

## Dependencies

### nui.nvim
- **GitHub**: https://github.com/MunifTanjim/nui.nvim
- **Wiki**: https://github.com/MunifTanjim/nui.nvim/wiki
- **Docs**: https://github.com/MunifTanjim/nui.nvim#readme
- **Latest Release**: v0.4.0 (May 2025)
- **Stars**: 2k+
- **License**: MIT

Components used in term.nvim:
- **Split**: Create split windows with relative sizing
  - Docs: https://github.com/MunifTanjim/nui.nvim/wiki/nui.split
  - Use case: Left and right panels for session list and terminal
  
- **Layout**: Complex multi-pane layouts with flexible box model

  - Docs: https://github.com/MunifTanjim/nui.nvim/wiki/nui.layout
  - Use case: Manage 20% left / 80% right layout
  
- **Popup**: Floating windows with borders and styling (optional for modals)
  - Docs: https://github.com/MunifTanjim/nui.nvim/wiki/nui.popup
  
- **Tree/Menu**: List components for session navigation
  - Docs: https://github.com/MunifTanjim/nui.nvim/wiki/nui.tree
  - Docs: https://github.com/MunifTanjim/nui.nvim/wiki/nui.menu

### plenary.nvim
- **GitHub**: https://github.com/nvim-lua/plenary.nvim
- **License**: MIT
- Features used:
  - Terminal API: `plenary.terminal.Terminal` for spawning terminal sessions
  - Job control: Running commands and capturing output
  - Path utilities: File/directory handling

## nui.nvim Code Example - Dashboard Layout

Creating a 20%/80% split layout similar to term.nvim:

```lua
local Split = require("nui.split")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

-- Left panel: 20% session list
local sessions_panel = Split({
  relative = "editor",
  position = "left",
  size = "20%",
  enter = true,
})

-- Right panel: 80% terminal display
local terminal_panel = Split({
  relative = "editor",
  position = "right",
  size = "80%",
})

-- Mount both panels
sessions_panel:mount()
terminal_panel:mount()

-- Handle keybindings
sessions_panel:map("n", "<C-l>", function()
  terminal_panel:focus()
end)

terminal_panel:map("n", "<C-h>", function()
  sessions_panel:focus()
end)

-- Cleanup on leave
sessions_panel:on(event.BufLeave, function()
  sessions_panel:unmount()
  terminal_panel:unmount()
end)
```

## References

- **nui.nvim Main**: https://github.com/MunifTanjim/nui.nvim
- **nui.nvim Split Component**: https://github.com/MunifTanjim/nui.nvim/wiki/nui.split
- **nui.nvim Layout Component**: https://github.com/MunifTanjim/nui.nvim/wiki/nui.layout
- **nui.nvim Popup Component**: https://github.com/MunifTanjim/nui.nvim/wiki/nui.popup
- **plenary.nvim Repository**: https://github.com/nvim-lua/plenary.nvim
- **plenary.nvim Terminal API**: https://github.com/nvim-lua/plenary.nvim#terminal
- **Neovim API**: https://neovim.io/doc/user/api.html

## Future Enhancements

- Session persistence across restarts
- Horizontal/vertical layout toggle
- Session renaming
- Output history/search
- Custom keybinding configuration