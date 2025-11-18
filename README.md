<h1 align="center">rest.nvim</h1>

<div>
  <h4 align="center">
    <a href="#dependencies">Dependencies</a> ·
    <a href="#installation">Installation</a> ·
    <a href="#usage">Usage</a> ·
    <a href="docs/">Documentation</a> ·
    <a href="docs/FEATURES.md">Features</a>
  </h4>
</div>

<div align="center">
  <a href="https://github.com/marco-souza/rest.nvim/releases/latest"
    ><img
      alt="Latest release"
      src="https://img.shields.io/github/v/release/marco-souza/rest.nvim?style=for-the-badge&logo=starship&logoColor=D9E0EE&labelColor=302D41&&color=d9b3ff&include_prerelease&sort=semver"
  /></a>
  <a href="https://github.com/marco-souza/rest.nvim/pulse"
    ><img
      alt="Last commit"
      src="https://img.shields.io/github/last-commit/marco-souza/rest.nvim?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"
  /></a>
  <a href="https://github.com/neovim/neovim/releases/latest"
    ><img
      alt="Latest Neovim"
      src="https://img.shields.io/github/v/release/neovim/neovim?style=for-the-badge&logo=neovim&logoColor=D9E0EE&label=Neovim&labelColor=302D41&color=99d6ff&sort=semver"
  /></a>
  <a href="http://www.lua.org/"
    ><img
      alt="Made with Lua"
      src="https://img.shields.io/badge/Built%20with%20Lua-grey?style=for-the-badge&logo=lua&logoColor=D9E0EE&label=Lua&labelColor=302D41&color=b3b3ff"
  /></a>
  <!-- <a href="https://www.buymeacoffee.com/marco-souza" -->
  <!--   ><img -->
  <!--     alt="Buy me a coffee" -->
  <!--     src="https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?style=for-the-badge&logo=buymeacoffee&logoColor=D9E0EE&label=Sponsor&labelColor=302D41&color=ffff99" -->
  <!-- /></a> -->
</div>
<hr />

A Neovim plugin that provides a REST client interface for making HTTP requests directly from your editor. Ideal for API testing and development workflows.

### Features

- **Postman-like Dashboard**: Dual-pane layout with request editor (30%) and response viewer (70%)
- **Async HTTP Requests**: Non-blocking async execution with animated loading spinner
- **Direct Command Execution**: `:Rest GET https://api.example.com` for instant requests
- **Interactive Dashboard**: `:Rest` to open the request/response editor
- **Support for `.rest` files**: Define and execute API requests from `.rest` files
- **Full HTTP Method Support**: GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD
- **Request Customization**: Edit headers, body, and URL in real-time
- **Layout Toggle**: Switch between horizontal and vertical layouts with `r` key
- **Response Formatting**: Automatic JSON pretty-printing and detection
- **Environment Variables**: Use `$VAR_NAME` syntax in requests
- **Syntax Highlighting**: Treesitter-powered highlighting for request and response
- **Word Wrap Toggle**: Easy toggling of line wrapping with `<C-w>`
- **Auto-load REST Files**: Automatically loads content from open `.rest` files
- **Seamless Integration**: Built with `nui.nvim` and `plenary.nvim`

## Dependencies

- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) - UI components
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Lua utilities and HTTP client

## Installation

Install with your preferred package manager:

### Using lazy.nvim

```lua
{
  "marco-souza/rest.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("rest").setup()
  end,
}
```

### Configuration

Customize the dashboard with options:

```lua
require("rest").setup({
  request_size = "30%",    -- Request pane size
  response_size = "70%",   -- Response pane size
  width = "80%",           -- Dashboard width
  height = "80%",          -- Dashboard height
  border = "rounded",      -- Border style
  margin = 0,              -- Margin around dashboard
})
```

For detailed configuration options, see the `DashboardOptions` type in `lua/rest/types.lua`.

## Usage

### Commands

The plugin provides the following commands:

- `:Rest` - Opens/toggles the REST client dashboard
- `:Rest GET https://api.example.com` - Execute GET request directly and show result
- `:Rest POST https://api.example.com` - Execute POST request (edit body in dashboard)
- `:Rest <METHOD> <URL>` - Execute any HTTP request directly

### Working with REST files

You can create `.rest` files to define your API requests. When you open the REST dashboard with a `.rest` file active, its content will be loaded into the dashboard.

Example REST file format:

```
GET https://api.example.com/users

# Headers
Content-Type: application/json
Authorization: Bearer your-token-here

# Body
{"query": "example"}
```

### Dashboard Usage

Once you have the dashboard open:

1. **Edit Request** (Left Pane - 30%):
   - Edit method, URL, headers, and body
   - Format: `METHOD URL` on first line
   - Headers: `Key: Value` format, one per line
   - Body: Everything after headers

2. **View Response** (Right Pane - 70%):
   - Press `<C-s>` to execute the request
   - Watch the animated spinner while loading
   - Response appears with status, headers, and body
   - JSON automatically formatted and pretty-printed

3. **Keyboard Shortcuts**:
    - `<C-s>` - Execute request
    - `<C-w>` - Toggle word wrap in response
    - `<C-y>` - Copy response to clipboard
    - `r` - Toggle between horizontal and vertical layout
    - `q` - Close the dashboard

### REST File Format

- First line: `METHOD URL` (e.g., `GET https://api.example.com`)
- Headers: `Key: Value` format, one per line
- Body: Everything after headers (JSON format supported)
- Comments: Lines starting with `#` are treated as comments

### Supported HTTP Methods

- GET
- POST
- PUT
- DELETE
- PATCH
- OPTIONS
- HEAD

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[Features](docs/FEATURES.md)** - Complete feature overview and roadmap
- **[Architecture](docs/ARCHITECTURE.md)** - Technical design and module structure
- **[Development](docs/DEVELOPMENT.md)** - Development guide for contributors
- **[Migration](docs/MIGRATION.md)** - Upgrade guide from previous versions

Start with [Documentation Index](docs/README.md) for a complete overview.

## License

MIT License. See [LICENSE](LICENSE) for details.