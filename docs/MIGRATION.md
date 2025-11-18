# Migration Guide - Old to New REST.nvim

## Overview

REST.nvim has been significantly refactored to improve UX, architecture, and performance. This guide helps migrate from the old version.

## What Changed

### Command Interface

#### Old
```vim
:Rest open   " Open dashboard
:Rest close  " Close dashboard
```

#### New
```vim
:Rest                           " Open/toggle dashboard
:Rest GET https://api.com       " Execute GET directly
:Rest POST https://api.com      " Execute POST directly
```

**Migration**: Both old commands still work but are mapped to new ones.

### UI Layout

#### Old
- Request Editor: 40%
- Response Viewer: 60%

#### New
- Request Editor: 30%
- Response Viewer: 70%

**Benefit**: More space for responses

### HTTP Execution

#### Old
```lua
-- Synchronous (blocking)
local response = curl.request(request)
```

#### New
```lua
-- Asynchronous (non-blocking)
http_client.execute_async(request, on_complete, on_error)
```

**Benefit**: UI never freezes during network requests

### Loading Indicator

#### Old
- Simple "loading..." text

#### New
- Animated unicode spinner: `⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏`

**Benefit**: Better visual feedback

## Backward Compatibility

### Preserved Features

✅ All existing features still work:
- REST file format unchanged
- Environment variables work the same
- Header format unchanged
- Body format unchanged
- Keybindings unchanged

### Old Commands Still Work

```vim
:Rest open   " Still works → maps to :Rest
:Rest close  " Still works → maps to :Rest
```

## Configuration Changes

### Old
```lua
require("rest").setup()  -- Used default only
```

### New
```lua
require("rest").setup({
  margin = 2,
  width = 120,
  height = 30,
  border = "rounded",
  request_pane_width = "30%",
  response_pane_width = "70%",
})
```

**Migration**: Existing setup() calls still work with defaults

## File Format (No Changes)

REST files work exactly the same:

```
GET https://api.example.com

# Headers
Accept: application/json

# Body
{"key": "value"}
```

This format is unchanged and fully compatible.

## Keybindings (No Changes)

All existing keybindings work the same:

| Key | Action |
|-----|--------|
| `<C-s>` | Execute request |
| `<C-y>` | Copy response |
| `r` | Toggle layout |
| `q` | Close dashboard |

## New Features You Get

### 1. Direct Execution
```vim
:Rest GET https://api.example.com
```

### 2. Async Requests
- No more frozen UI during loading
- Smooth spinner animation

### 3. Better Response Pane
- 70% of screen (was 60%)
- Better visibility for responses

### 4. State Management
- Internal state tracking
- Foundation for future features

## Breaking Changes

**None!** This is a backward-compatible refactor.

- Old configurations still work
- Old commands still work
- Old REST files still work
- All keybindings unchanged

## Migration Steps

### Step 1: Update Plugin
```lua
-- lazy.nvim
{
  "marco-souza/rest.nvim",
  -- No changes needed here
}

-- packer.nvim
use "marco-souza/rest.nvim"
-- No changes needed here
```

### Step 2: (Optional) Update Setup
```lua
-- Before
require("rest").setup()

-- After (if you want new options)
require("rest").setup({
  request_pane_width = "25%",  -- Even smaller request pane
  response_pane_width = "75%", -- More response space
})
```

### Step 3: (Optional) Learn New Commands
```vim
" New direct execution (optional)
:Rest GET https://api.github.com/users

" Still use dashboard for complex requests
:Rest
```

## Troubleshooting

### Issue: `:Rest open` not working

**Solution**: It now maps to `:Rest`. Both work.

### Issue: Old configuration not loading

**Solution**: Your configuration is still valid. No changes needed.

### Issue: Requests still feel slow

**Solution**: New version is async. If it feels slow, it's network, not the plugin.

### Issue: Loader spinner not showing

**Solution**: Spinner shows only during requests. If no spinner, your terminal might not support Unicode spinners. Set `SPINNER_INTERVAL` higher:

```lua
-- In ui/loader.lua
local SPINNER_INTERVAL = 200  -- Increase from 100
```

## Features Available Now (That Weren't Before)

1. **Direct Command Execution**
   ```vim
   :Rest GET https://api.example.com
   ```

2. **Async/Non-blocking Requests**
   - Plugin never freezes during HTTP calls
   - UI remains responsive

3. **Animated Loading Indicator**
   - Smooth spinner animation
   - Better UX feedback

4. **Larger Response Pane**
   - 70% instead of 60%
   - Better for viewing large responses

5. **Internal State Management**
   - Foundation for future features
   - Better plugin architecture

## Upgrading Without Breaking Your Workflow

Your current workflow doesn't need to change:

1. Keep using REST files
2. Keep using `:Rest` to open dashboard
3. Keep using same keybindings
4. Add new commands when you want them

**Everything still works!**

## Questions?

### Can I use REST files like before?

Yes, exactly the same format and workflow.

### Are my keybindings still valid?

Yes, all keybindings are unchanged.

### Will my custom configuration break?

No, it will still work. Defaults have sensible values.

### Can I go back to old layout ratio?

Yes, in setup:
```lua
require("rest").setup({
  request_pane_width = "40%",
  response_pane_width = "60%",
})
```

### Is direct execution required?

No, it's optional. Dashboard mode works exactly as before.

## Summary

- ✅ Fully backward compatible
- ✅ All existing features work
- ✅ New features are optional
- ✅ No configuration changes required
- ✅ Same REST file format
- ✅ Same keybindings
- ✅ Better performance and UX

**Your transition should be seamless!**
