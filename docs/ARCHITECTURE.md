# REST.nvim Architecture

## Overview

REST.nvim is a modular Neovim plugin for making HTTP requests with a Postman-like interface. The architecture emphasizes separation of concerns, async execution, and state management.

## Module Structure

```
lua/rest/
├── init.lua              # Plugin initialization & configuration
├── cmd.lua               # Command routing & parsing
├── types.lua             # Lua type annotations
├── ui/
│   ├── dashboard.lua    # Main UI layout (dual-pane)
│   └── loader.lua       # Loading indicator component
└── utils/
    ├── state.lua        # Centralized state management
    ├── http_client.lua  # HTTP client wrapper (async)
    ├── rest_parser.lua  # REST file parser
    └── env.lua          # Environment variable substitution
```

## Core Components

### 1. State Management (`utils/state.lua`)

**Purpose**: Centralized store for all application state

**Responsibilities**:
- Store current request (method, URL, headers, body)
- Store current response (status, body, headers)
- Track loading state
- Store error messages
- Notify subscribers of state changes

**API**:
```lua
state.set_request(request)     -- Set request
state.get_request()            -- Get request
state.set_response(response)   -- Set response
state.get_response()           -- Get response
state.set_loading(bool)        -- Set loading flag
state.is_loading()             -- Check if loading
state.set_error(msg)           -- Set error
state.get_error()              -- Get error
state.subscribe(callback)      -- Subscribe to changes
state.reset()                  -- Reset all state
```

**Pattern**: Observer pattern for UI reactivity

### 2. HTTP Client (`utils/http_client.lua`)

**Purpose**: Wrapper around plenary.curl with async support

**Responsibilities**:
- Execute HTTP requests without blocking UI
- Handle success/error callbacks
- Format responses for display
- Validate requests

**API**:
```lua
http_client.execute_async(request, on_complete, on_error)
http_client.execute_sync(request)          -- Blocking (legacy)
http_client.format_response(response)      -- Format for display
```

**Async Pattern**:
```lua
vim.schedule(function()
  -- Execute in next event loop cycle
  local result = curl.request(...)
  on_complete(result)
end)
```

### 3. Loader Component (`ui/loader.lua`)

**Purpose**: Animated loading indicator

**Responsibilities**:
- Display spinner animation
- Manage timer for frame rotation
- Hide/show animation

**API**:
```lua
loader.show(bufnr)     -- Show spinner in buffer
loader.hide()          -- Hide spinner
loader.is_visible()    -- Check visibility
```

**Animation**: Unicode spinner frames with 100ms interval
```
Frames: ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
```

### 4. Dashboard UI (`ui/dashboard.lua`)

**Purpose**: Main user interface with dual-pane layout

**Layout**:
```
┌─────────────────────────────────────┐
│  Request Editor (30%) │ Response (70%) │
│                       │                │
│  - Method             │ - Status       │
│  - URL                │ - Headers      │
│  - Headers            │ - Body         │
│  - Body               │ - Loader       │
└─────────────────────────────────────┘
```

**Responsibilities**:
- Render request and response panes
- Handle user input (keybindings)
- Trigger request execution
- Format and display responses

**Keybindings**:
- `<C-s>` - Execute request
- `<C-y>` - Copy response
- `r` - Toggle layout (horizontal/vertical)
- `q` - Close dashboard

### 5. Command Router (`cmd.lua`)

**Purpose**: Parse and route Neovim commands

**Responsibilities**:
- Parse command arguments
- Distinguish between direct execution and dashboard mode
- Extract HTTP method and URL
- Parse optional headers

**Command Patterns**:
```vim
:Rest                    " Open dashboard
:Rest GET url            " Direct execution
:Rest POST url -H "..."  " Direct execution with headers
```

### 6. Parser (`utils/rest_parser.lua`)

**Purpose**: Parse .rest files into structured requests

**Format**:
```
METHOD URL

# Headers
Key1: Value1
Key2: Value2

# Body
{"key": "value"}
```

**Features**:
- Comments (lines starting with #)
- Environment variable substitution
- JSON body parsing

### 7. Initialization (`init.lua`)

**Purpose**: Plugin entry point

**Responsibilities**:
- Define default configuration
- Setup command registration
- Provide setup() function

**Configuration**:
```lua
{
  margin = 2,
  width = 120,
  height = 30,
  border = "rounded",
  request_pane_width = "30%",
  response_pane_width = "70%",
}
```

## Data Flow

### Dashboard Mode

```
User Input
    ↓
cmd.lua (route to dashboard)
    ↓
dashboard.open()
    ↓
Display request/response panes
    ↓
User edits request
    ↓
User presses <C-s>
    ↓
Parse request → state.set_request()
    ↓
state.set_loading(true) → loader.show()
    ↓
http_client.execute_async()
    ↓
vim.schedule() executes in next event loop
    ↓
Response received → state.set_response()
    ↓
loader.hide() → format_response()
    ↓
Display response in pane
```

### Direct Execution Mode

```
User Input: :Rest GET url
    ↓
cmd.lua parses METHOD and URL
    ↓
execute_direct_request()
    ↓
state.set_request()
    ↓
http_client.execute_async()
    ↓
vim.schedule()
    ↓
Response → floating window
```

## State Management Pattern

### Subscriber Pattern

```lua
-- Register listener
state.subscribe(function(key, new_val, old_val)
  if key == "loading" then
    if new_val then
      loader.show(bufnr)
    else
      loader.hide()
    end
  elseif key == "response" then
    display_response(new_val)
  end
end)

-- Update state
state.set_loading(true)     -- Triggers callback
```

## Async Execution Model

### Non-blocking Pattern

```lua
-- User action (blocks)
vim.api.nvim_buf_get_lines()

-- Async HTTP request (non-blocking)
vim.schedule(function()
  local response = curl.request()
  on_complete(response)
end)

-- UI remains responsive
-- Spinner continues animating
```

## Type System

Lua annotations for IDE support:

```lua
---@class Request
---@field method string
---@field url string
---@field headers table<string, string>
---@field body string|nil

---@class Response
---@field status number
---@field body string
---@field headers table<string, string>
---@field error string|nil
```

## Error Handling

### Levels

1. **Request Validation** - Catch invalid method/URL
2. **HTTP Errors** - Handle network failures
3. **Parsing Errors** - Handle malformed responses
4. **UI Errors** - Graceful error display

### Error Flow

```
Error occurs
    ↓
on_error(error_msg)
    ↓
state.set_error(msg)
    ↓
loader.hide()
    ↓
Display error in response pane
```

## Performance Considerations

1. **Async Execution**
   - HTTP requests don't block the event loop
   - UI remains responsive during loading

2. **Spinner Animation**
   - Timer-based frame rotation
   - Cleanup on completion

3. **Buffer Operations**
   - Batch updates where possible
   - Avoid redundant redraws

## Extensibility

### Adding New Features

1. **New Request Type**
   - Extend `utils/http_client.lua`
   - Update `types.lua` if needed

2. **New UI Component**
   - Create module in `ui/`
   - Integrate with dashboard.lua

3. **New Command**
   - Add to `cmd.lua` routing
   - Update command parser

### Plugin Configuration

Users can override defaults:

```lua
require("rest").setup({
  width = 150,
  height = 40,
  border = "double",
})
```

## Dependencies

- **nui.nvim** - UI components (Layout, Popup)
- **plenary.nvim** - curl client and utilities

## Testing

All modules are tested for:
- Compilation and loading
- State management
- Command parsing
- HTTP client structure

Run validation:
```bash
nvim --noplugin -u NONE -c "set runtimepath+=$(pwd)" \
  -c "lua require('rest'); print('OK')" -c "qa!"
```

## Future Improvements

- [ ] Request history
- [ ] Collections support
- [ ] Environment presets
- [ ] Pre/post-request scripts
- [ ] GraphQL support
- [ ] Syntax highlighting for responses
