<h1 align="center">term.nvim</h1>

<div>
  <h4 align="center">
    <a href="#dependencies">Dependencies</a> ·
    <a href="#usage">Usage</a> ·
    <a href="#features">Features</a>
  </h4>
</div>

<div align="center">
  <a href="https://github.com/marco-souza/term.nvim/releases/latest"
    ><img
      alt="Latest release"
      src="https://img.shields.io/github/v/release/marco-souza/term.nvim?style=for-the-badge&logo=starship&logoColor=D9E0EE&labelColor=302D41&&color=d9b3ff&include_prerelease&sort=semver"
  /></a>
  <a href="https://github.com/marco-souza/term.nvim/pulse"
    ><img
      alt="Last commit"
      src="https://img.shields.io/github/last-commit/marco-souza/term.nvim?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"
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
</div>
<hr />

A Neovim plugin for managing multiple terminal sessions with an interactive dashboard. Run, monitor, and control multiple terminal instances directly from your editor.

### Features

- Manage multiple terminal sessions simultaneously
- Interactive dashboard with dual-pane layout
- Left panel: List of open terminal sessions (20%)
- Right panel: Active terminal display (80%)
- Execute commands with `:Term <cmd>`
- Create, switch, and close terminal sessions
- Seamless integration with `nui.nvim` and `plenary.nvim`

## Dependencies

- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) - UI components
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Lua utilities

## Installation

Install with your preferred package manager:

### Using lazy.nvim

```lua
{
  "marco-souza/term.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("term").setup()
  end,
}
```

## Usage

### Commands

The plugin provides the following commands:

- `:Term <cmd>` - Open a terminal with the specified command
- `:Term` - Open the terminal manager dashboard
- `:Term list` - List all open terminal sessions
- `:Term close` - Close the current terminal session

### Dashboard Navigation

Once you have the dashboard open:

1. **Left Panel**: View all open terminal sessions
   - Select a terminal to switch between sessions
   - See session name and status

2. **Right Panel**: Interact with the active terminal
   - Full terminal emulation support
   - Execute commands within the session

3. **Keybindings**:
   - `<C-l>` / `<C-h>` - Switch focus between panels
   - `j/k` - Navigate terminal list (left panel)
   - `<CR>` - Select terminal session
   - `d` - Delete/close terminal session
   - `n` - Create new terminal session
   - `q` - Close dashboard

### Examples

```vim
:Term npm start      " Opens a new terminal running npm start
:Term python script.py
:Term               " Opens the terminal manager dashboard
:Term list          " Shows list of active sessions
:Term close         " Closes current session
```

## License

MIT License. See [LICENSE](LICENSE) for details.
