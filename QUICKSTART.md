# REST.nvim Quick Start

## Installation

Using `lazy.nvim`:

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

## 30 Second Usage

### Open Dashboard
```vim
:Rest
" Left pane: Edit your request
" Right pane: See the response
<C-s>  " Execute request
q      " Close
```

### Quick API Call
```vim
:Rest GET https://api.github.com/users/marco-souza
" Results show in floating window
```

## Common Commands

```vim
:Rest GET https://httpbin.org/get
:Rest POST https://httpbin.org/post
:Rest PUT https://httpbin.org/put
:Rest DELETE https://httpbin.org/delete
```

## Keyboard Shortcuts

In dashboard:
- `<C-s>` - Execute request
- `<C-y>` - Copy response
- `r` - Toggle layout
- `q` - Close

## Example: Create REST File

**api.rest**:
```
GET https://api.github.com/users/marco-souza

Accept: application/json
User-Agent: REST.nvim
```

Then open it:
```vim
:Rest
" Dashboard loads with your request
<C-s>  " Execute
```

## Environment Variables

In request:
```
GET $API_BASE_URL/users/$USER_ID

Authorization: Bearer $API_TOKEN
```

Set environment:
```bash
export API_BASE_URL="https://api.example.com"
export API_TOKEN="your-token"
```

## With Headers

```vim
:Rest POST https://httpbin.org/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123"
```

## Layout Modes

- **Horizontal** (default): Request left, Response right
- **Vertical**: Request top, Response bottom
- Press `r` to toggle

## Next Steps

- Read [docs/](docs/) for detailed guides
- Check [FEATURES.md](docs/FEATURES.md) for all capabilities
- See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for how it works
- Review [DEVELOPMENT.md](docs/DEVELOPMENT.md) to contribute

## Support

- Issue: Check [docs/DEVELOPMENT.md#troubleshooting](docs/DEVELOPMENT.md#troubleshooting)
- Question: Open a GitHub issue
- Contribute: See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)

**That's it! Start making API requests from Neovim! 🚀**
