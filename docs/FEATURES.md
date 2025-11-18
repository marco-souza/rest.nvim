# REST.nvim Features

## Core Features

### 1. Interactive Dashboard

**Description**: Dual-pane interface for composing and viewing HTTP requests

**Features**:
- **Request Editor (Left 30%)**
   - Edit HTTP method, URL, headers, and body
   - Real-time editing with vim keybindings
   - Treesitter syntax highlighting (bash)
   - Environment variable substitution (`$VAR_NAME`)

 - **Response Viewer (Right 70%)**
   - Display response status code
   - Show response headers
   - Format and display response body with JSON syntax highlighting
   - Animated loading indicator during request
   - Toggleable word wrap with `<C-w>`

**Keyboard Shortcuts**:
- `<C-s>` - Execute request
- `<C-w>` - Toggle word wrap in response
- `<C-y>` - Copy response to clipboard
- `r` - Toggle between horizontal and vertical layout
- `q` - Close dashboard

**Example**:
```vim
:Rest
" Opens interactive dashboard
```

### 2. Direct Request Execution

**Description**: Execute HTTP requests from command line without opening dashboard

**Features**:
- Quick request execution
- Display result in floating window
- Support for all HTTP methods
- Optional headers via `-H` flag

**Examples**:
```vim
:Rest GET https://api.github.com/users/marco-souza
:Rest POST https://httpbin.org/post -H "Content-Type: application/json"
:Rest DELETE https://api.example.com/resource/123
```

**Result**: Floating window with formatted response

### 3. REST File Support

**Description**: Define API requests in `.rest` files and execute them

**File Format**:
```
METHOD URL

# Headers
Header1: Value1
Header2: Value2

# Body
{"key": "value"}
```

**Example**:
```
# github_api.rest
GET https://api.github.com/users/marco-souza

Accept: application/json
User-Agent: rest.nvim/1.0
```

**Usage**:
```vim
:Rest
" When buffer is a .rest file, dashboard loads its content
```

**Benefits**:
- Share API requests via version control
- Document API workflows
- Organize multiple requests
- Version control request configurations

### 4. Async Execution

**Description**: Non-blocking HTTP request execution

**Features**:
- Requests execute without blocking the UI
- Event loop continues processing input
- Animated spinner shows request progress
- Vim remains fully responsive during loading

**Technical Details**:
- Uses `vim.schedule()` for async execution
- plenary.curl handles HTTP
- Callbacks for success/error handling

**Performance**:
- Request execution: Instant UI return
- No frozen editor during network I/O
- Spinner animation continues smoothly

### 5. Loading Indicator

**Description**: Visual feedback during HTTP requests

**Features**:
- Animated unicode spinner
- 100ms frame rotation
- Displays "⠋ Loading..." during request
- Automatic cleanup on completion

**Spinner Animation**:
```
⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏ (repeats)
```

**UX Benefits**:
- Clear indication request is processing
- No "hanging" feeling
- Professional appearance

### 6. Response Formatting

**Description**: Automatic formatting of HTTP responses

**Features**:
- **JSON Detection**: Automatically pretty-prints JSON
- **Status Display**: Shows HTTP status code prominently
- **Header Display**: Lists response headers
- **Text Display**: Shows raw text if not JSON

**Example Output**:
```
Status: 200

Headers:
  content-type: application/json
  content-length: 1234

{
  "key": "value",
  "nested": {
    "data": true
  }
}
```

### 7. Environment Variables

**Description**: Use environment variables in requests

**Syntax**: `$VARIABLE_NAME`

**Example**:
```
GET $API_BASE_URL/users/$USER_ID

Authorization: Bearer $API_TOKEN
```

**Usage in Dashboard**:
```
GET https://api.example.com/users

# Headers
Authorization: Bearer $GITHUB_TOKEN

# Body
{"token": "$SESSION_TOKEN"}
```

**Environment Setup**:
```bash
export API_BASE_URL="https://api.example.com"
export GITHUB_TOKEN="ghp_xxx"
```

### 8. Clipboard Integration

**Description**: Copy responses to clipboard

**Keybinding**: `<C-y>`

**Use Cases**:
- Copy API response for sharing
- Paste response into another document
- Quick data extraction

**Features**:
- Copies full response text
- Works in dashboard and direct execution
- Instant copy with notification

### 9. Layout Toggle

**Description**: Switch between horizontal and vertical layouts

**Keybinding**: `r`

**Layouts**:

**Horizontal (Default)**:
```
┌─────────────┬──────────────┐
│  Request    │   Response   │
│   (30%)     │    (70%)     │
└─────────────┴──────────────┘
```

**Vertical**:
```
┌──────────────────────────┐
│     Request (30%)        │
├──────────────────────────┤
│     Response (70%)       │
└──────────────────────────┘
```

### 10. Error Handling

**Description**: Graceful error handling and reporting

**Error Types**:
- **Network Errors**: "Connection refused", timeouts
- **Invalid Requests**: Missing method or URL
- **Parsing Errors**: Malformed JSON responses
- **Server Errors**: 4xx and 5xx status codes

**Error Display**:
- Shows in response pane
- Notification for critical errors
- Suggestions for common issues

**Example**:
```
ERROR: Connection refused (Unable to connect to https://invalid.url)
```

## Advanced Features

### State Management

**Description**: Centralized state tracking

**Tracked State**:
- Current request
- Current response
- Loading status
- Error messages

**API Access**:
```lua
local state = require("rest.utils.state")
local current_request = state.get_request()
local is_loading = state.is_loading()
```

### Extensibility

**Description**: Plugin architecture for customization

**Extension Points**:
- New HTTP methods
- Custom request parsing
- Response formatting hooks
- UI customizations

**Example - Add Custom Header**:
```lua
local dashboard = require("rest.ui.dashboard")
local http_client = require("rest.utils.http_client")

-- Intercept and modify requests
local original_execute = http_client.execute_async
function http_client.execute_async(request, ...)
  request.headers["X-Custom"] = "value"
  original_execute(request, ...)
end
```

### Configuration

**Description**: Customize plugin behavior

**Options**:
```lua
require("rest").setup({
  margin = 2,              -- Margin around dashboard
  width = 120,             -- Dashboard width
  height = 30,             -- Dashboard height
  border = "rounded",      -- Border style
  request_pane_width = "30%",   -- Request pane width
  response_pane_width = "70%",  -- Response pane width
})
```

## Feature Comparison

### REST.nvim vs Postman

| Feature | REST.nvim | Postman |
|---------|-----------|---------|
| In-editor execution | ✅ | ❌ |
| Collections | ⏳ | ✅ |
| Environment switching | ⏳ | ✅ |
| Pre-request scripts | ⏳ | ✅ |
| GraphQL support | ⏳ | ✅ |
| Free & open source | ✅ | ❌ |
| Neovim integration | ✅ | ❌ |
| Vim keybindings | ✅ | ❌ |

## Future Features (Roadmap)

### v2.0
- [ ] Request history
- [ ] Saved collections
- [ ] Environment presets
- [ ] Pre/post-request scripts

### v2.5
- [ ] GraphQL support
- [ ] HTML response formatting
- [ ] XML response formatting
- [ ] Response syntax highlighting

### v3.0
- [ ] Request testing/assertions
- [ ] Load testing
- [ ] Request templating
- [ ] OAuth2 flow support

## Feature Requests

Users can request new features via GitHub issues:
1. Check existing issues
2. Describe use case
3. Suggest implementation approach
4. Provide examples

## Changelog

### v1.0 (Current)
- Dual-pane dashboard with treesitter syntax highlighting
- Async HTTP requests
- Loading indicator
- Direct command execution
- REST file support with auto-load
- Environment variables
- Response formatting with JSON highlighting
- Clipboard integration
- Word wrap toggling
- Layout toggling (horizontal/vertical)

---

For more details, see:
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical design
- [README.md](../README.md) - User guide
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide
