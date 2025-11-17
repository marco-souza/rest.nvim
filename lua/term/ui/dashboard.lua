local M = {}

local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local terminal_manager = require("term.utils.terminal")

local _defaults = {
  width = 120,
  height = 30,
}

local _state = {
  active_session_id = nil,
  session_list = {},
}

---Render the session list in the left panel
---@param left_panel any: The left panel popup
local function _render_sessions(left_panel)
  if not left_panel or not left_panel.bufnr or not vim.api.nvim_buf_is_valid(left_panel.bufnr) then
    return
  end

  local sessions = terminal_manager.list()
  _state.session_list = sessions

  local session_lines = {
    "=== Sessions ===",
    "",
  }

  for i, session in ipairs(sessions) do
    local marker = (session.id == _state.active_session_id) and "* " or "  "
    table.insert(
      session_lines,
      string.format("%s[%d] %s", marker, i, session.cmd)
    )
  end

  if #sessions == 0 then
    table.insert(session_lines, "No active sessions")
  end

  table.insert(session_lines, "")
  table.insert(session_lines, "=== Keys ===")
  table.insert(session_lines, "S-j - Next Session")
  table.insert(session_lines, "S-k - Prev Session")
  table.insert(session_lines, "S-c - Create Terminal")
  table.insert(session_lines, "S-r - Rename Session")
  table.insert(session_lines, "S-x - Delete Session")
  table.insert(session_lines, "q   - Close Dashboard")

  vim.api.nvim_buf_set_lines(
    left_panel.bufnr,
    0,
    -1,
    false,
    session_lines
  )
end

---@param opts DashboardOptions|nil
local function toggle(opts)
  opts = vim.tbl_deep_extend("force", _defaults, opts or {})

  -- Left panel: session list (20%)
  local left_panel = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      padding = { 0, 1 },
    },
    win_options = {
      winhighlight = "Normal:NormalFloat",
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  -- Right panel: terminal (80%)
  local right_panel = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      padding = { 0, 1 },
    },
    win_options = {
      winhighlight = "Normal:NormalFloat",
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  })

  -- Create layout with 20%/80% split
  local layout = Layout(
    {
      relative = "editor",
      position = "50%",
      size = {
        width = opts.width,
        height = opts.height,
      },
    },
    Layout.Box({
      Layout.Box(left_panel, { size = "20%" }),
      Layout.Box(right_panel, { size = "80%" }),
    }, { dir = "row" })
  )

  layout:mount()

  -- Forward declarations for recursive functions
  local next_session, prev_session, create_new_terminal, rename_session, delete_session, switch_to_session

  -- Function to switch to a session and display it
  function switch_to_session(session_id)
    if not terminal_manager.exists(session_id) then
      return
    end

    _state.active_session_id = session_id
    terminal_manager.switch(session_id)

    local session = terminal_manager.get_by_id(session_id)
    local winid = right_panel.winid

    if winid and vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_current_win(winid)

      -- Check if session has a buffer already
      if not session.bufnr or not vim.api.nvim_buf_is_valid(session.bufnr) then
        -- Create new terminal buffer
        local shell = vim.env.SHELL or "/bin/bash"
        local cmd = session.cmd
        local terminal_cmd = shell .. " -c " .. cmd
        session.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(winid, session.bufnr)
        vim.fn.termopen(terminal_cmd, {
          on_exit = function()
            -- Close session when terminal exits
            terminal_manager.close(session_id)
          end,
        })

        -- Set keymaps for new terminal buffer
        vim.api.nvim_win_call(winid, function()
          vim.keymap.set("t", "<S-j>", next_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-k>", prev_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-c>", create_new_terminal, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-r>", rename_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-x>", delete_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "q", function()
            layout:unmount()
          end, { noremap = true, buffer = true })
        end)

        vim.cmd("startinsert")
      else
        -- Reuse existing buffer
        vim.api.nvim_win_set_buf(winid, session.bufnr)
        
        -- Set keymaps for reused buffer
        vim.api.nvim_win_call(winid, function()
          vim.keymap.set("t", "<S-j>", next_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-k>", prev_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-c>", create_new_terminal, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-r>", rename_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "<S-x>", delete_session, { noremap = true, buffer = true })
          vim.keymap.set("t", "q", function()
            layout:unmount()
          end, { noremap = true, buffer = true })
          
          -- Enter terminal mode for reused buffer
          vim.cmd("startinsert")
        end)
      end
    end

    _render_sessions(left_panel)
  end

  -- Navigation functions
  function next_session()
    if #_state.session_list == 0 then
      return
    end
    local current_idx = nil
    for i, session in ipairs(_state.session_list) do
      if session.id == _state.active_session_id then
        current_idx = i
        break
      end
    end
    if not current_idx then
      return
    end
    local next_idx = current_idx < #_state.session_list and current_idx + 1 or 1
    switch_to_session(_state.session_list[next_idx].id)
  end

  function prev_session()
    if #_state.session_list == 0 then
      return
    end
    local current_idx = nil
    for i, session in ipairs(_state.session_list) do
      if session.id == _state.active_session_id then
        current_idx = i
        break
      end
    end
    if not current_idx then
      return
    end
    local prev_idx = current_idx > 1 and current_idx - 1 or #_state.session_list
    switch_to_session(_state.session_list[prev_idx].id)
  end

  function create_new_terminal()
    local input = Input({
      position = "50%",
      size = {
        width = 50,
        height = 3,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = "Normal:NormalFloat",
      },
    }, {
      prompt = "Command: ",
      default_value = vim.env.SHELL or "/bin/bash",
      on_submit = function(value)
        if value and value ~= "" then
          local session = terminal_manager.create(value)
          if session then
            switch_to_session(session.id)
          end
        end
      end,
    })
    input:mount()
  end

  function rename_session()
    local active_session = terminal_manager.get_by_id(_state.active_session_id)
    if not active_session then
      vim.notify("No active session", vim.log.levels.WARN)
      return
    end

    local input = Input({
      position = "50%",
      size = {
        width = 50,
        height = 3,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = "Normal:NormalFloat",
      },
    }, {
      prompt = "Rename to: ",
      default_value = active_session.cmd,
      on_submit = function(value)
        if value and value ~= "" then
          active_session.cmd = value
          _render_sessions(left_panel)
        end
      end,
    })
    input:mount()
  end

  function delete_session()
    if not _state.active_session_id then
      vim.notify("No active session", vim.log.levels.WARN)
      return
    end

    terminal_manager.close(_state.active_session_id)
    vim.notify("Session deleted", vim.log.levels.INFO)
  end

  -- Listen for session close events
  terminal_manager.on("on_session_closed", function(data)
    _render_sessions(left_panel)

    -- If closed session was active, switch to another
    if data.id == _state.active_session_id then
      local sessions = terminal_manager.list()
      if #sessions > 0 then
        switch_to_session(sessions[1].id)
      else
        _state.active_session_id = nil
      end
    end
  end)

  -- Determine initial session
  local initial_session_id
  if opts.cmd then
    -- Create new session if command is provided
    local session = terminal_manager.create(opts.cmd)
    initial_session_id = session and session.id or nil
  else
    -- Use existing active session or create default
    local active = terminal_manager.get_active()
    if active then
      initial_session_id = active.id
    else
      -- No existing session, create default shell
      local shell = vim.env.SHELL or "/bin/bash"
      local session = terminal_manager.create(shell)
      initial_session_id = session and session.id or nil
    end
  end

  -- Render initial session list
  _render_sessions(left_panel)

  -- Display initial session
  if initial_session_id then
    switch_to_session(initial_session_id)
  end

  -- Map keys for sidebar
  if vim.api.nvim_win_is_valid(left_panel.winid) then
    left_panel:map("n", "<S-j>", next_session, { noremap = true })
    left_panel:map("n", "<S-k>", prev_session, { noremap = true })
    left_panel:map("n", "<S-c>", create_new_terminal, { noremap = true })
    left_panel:map("n", "<S-r>", rename_session, { noremap = true })
    left_panel:map("n", "<S-x>", delete_session, { noremap = true })
  end

  left_panel:map("n", "q", function()
    layout:unmount()
  end, { noremap = true })

  -- Auto-enter terminal mode when entering terminal buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = right_panel.bufnr,
    callback = function()
      if vim.bo.buftype == "terminal" then
        vim.cmd("startinsert")
      end
    end,
  })

  -- Close dashboard when losing focus
  local close_dashboard = function()
    local current_win = vim.api.nvim_get_current_win()
    if current_win ~= left_panel.winid and current_win ~= right_panel.winid then
      pcall(function()
        layout:unmount()
      end)
    end
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    callback = close_dashboard,
    once = true,
  })
end

M.toggle = toggle

return M