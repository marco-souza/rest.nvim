# REST.nvim Documentation

Welcome to REST.nvim documentation. This folder contains detailed information about the plugin.

## Quick Links

- **[Features](FEATURES.md)** - Complete feature overview
- **[Architecture](ARCHITECTURE.md)** - Technical design and module structure
- **[Development](DEVELOPMENT.md)** - Development guide for contributors
- **[Migration](MIGRATION.md)** - Migration guide from old version

## Documentation Structure

### For Users

Start here if you're using REST.nvim:

1. **[Features](FEATURES.md)** - Learn what REST.nvim can do
2. **[Migration](MIGRATION.md)** - Upgrade from old version (if needed)
3. **[Main README](../README.md)** - Installation and basic usage

### For Developers

Start here if you want to contribute or extend REST.nvim:

1. **[Architecture](ARCHITECTURE.md)** - Understand how it works
2. **[Development](DEVELOPMENT.md)** - Set up development environment
3. **Look at source code** - `lua/rest/` directory, especially `lua/rest/types.lua`

## Key Concepts

### Dual-Pane Dashboard

```
┌──────────────────────────────────┐
│  Request (30%) │ Response (70%) │
│  - Method      │ - Status       │
│  - URL         │ - Headers      │
│  - Headers     │ - Body         │
│  - Body        │ - Loader       │
└──────────────────────────────────┘
```

### Async Execution

HTTP requests execute without blocking the UI:
- You can continue editing while loading
- Spinner shows request progress
- Response appears when ready

### State Management

Central state store manages:
- Current request
- Current response
- Loading status
- Error messages

### Modular Architecture

```
init.lua (setup)
    ↓
cmd.lua (commands)
    ├─→ dashboard.lua (UI)
    └─→ http_client.lua (HTTP)
        └─→ state.lua (state)
            └─→ loader.lua (spinner)
```

## Common Tasks

### Make an API Request

```vim
:Rest GET https://api.example.com
```

### Edit a Complex Request

```vim
:Rest
" Edits request in left pane
" <C-s> to execute
" Results in right pane
```

### Use from REST File

```vim
" In api.rest file:
GET https://api.github.com/users

Accept: application/json

" Then: :Rest
```

### Copy Response

```vim
" After request completes:
<C-y>  " Copies response to clipboard
```

## Advanced Topics

### Custom Configuration

See [Development](DEVELOPMENT.md#module-development)

### Creating Extensions

See [Architecture](ARCHITECTURE.md#extensibility)

### Contributing

See [Development](DEVELOPMENT.md)

## FAQ

### Is REST.nvim backward compatible?

Yes! See [Migration](MIGRATION.md) for details.

### Can I use my old REST files?

Yes, format is unchanged.

### How do I report bugs?

Open an issue on GitHub with:
- Neovim version
- Error message
- Steps to reproduce

### How do I request features?

Open a feature request on GitHub with:
- Description of use case
- Why it would be helpful
- Suggested implementation

### Where's the source code?

In `lua/rest/` directory:
- `init.lua` - Plugin entry point
- `cmd.lua` - Command routing
- `ui/dashboard.lua` - Main interface
- `utils/` - Helper modules

## Resources

### Neovim
- [Neovim Lua Guide](https://neovim.io/doc/user/lua.html)
- [Neovim API Docs](https://neovim.io/doc/user/api.html)

### Dependencies
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

### HTTP Testing
- [Postman](https://www.postman.com/) - Inspiration
- [curl](https://curl.se/) - What we use under the hood
- [httpbin.org](https://httpbin.org/) - Test API

## Getting Help

1. Check documentation in this folder
2. Search GitHub issues
3. Open a new issue if not found
4. Check [Development](DEVELOPMENT.md) for debugging tips

---

**Last Updated**: November 17, 2025  
**Version**: 1.0  
**Status**: Production Ready
