<h1 align="center">rest.nvim</h1>

<div>
  <h4 align="center">
    <a href="#dependencies">Dependencies</a> ·
    <a href="#usage">Usage</a>
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

- Execute HTTP requests directly from Neovim
- Interactive REST client dashboard
- Support for `.rest` files to define API requests
- View and edit request headers, body, and URL
- Toggle between horizontal and vertical layouts
- Supports all major HTTP methods: GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD
- Seamless integration with `nui.nvim` and `plenary.nvim`
- Support for using environment variables in `.rest` files and dashboard

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

## Usage

### Commands

The plugin provides the following commands:

- `:Rest open` - Opens the REST client dashboard
- `:Rest close` - Closes the REST client dashboard

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

1. Edit your request in the left panel
2. Press `<C-s>` to execute the request
3. View the response in the right panel
4. Press `r` to toggle between horizontal and vertical layout
5. Press `q` to close the dashboard

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

## License

MIT License. See [LICENSE](LICENSE) for details.
