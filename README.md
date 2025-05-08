# rest.nvim

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
  "username/rest.nvim",
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
