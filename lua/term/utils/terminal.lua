local M = {}

---@class TerminalSession
---@field id string: Unique session identifier
---@field cmd string: Command that was executed
---@field terminal any: plenary.terminal.Terminal instance
---@field created_at number: Timestamp when session was created

local _sessions = {}
local _active_session_id = nil
local _session_counter = 0
local _callbacks = {
  on_session_created = {},
  on_session_closed = {},
  on_active_changed = {},
}

---Generate unique session ID
---@return string
local function _generate_id()
  _session_counter = _session_counter + 1
  return string.format(
    "session_%d_%d",
    _session_counter,
    math.floor(os.time() * 1000) % 1000000
  )
end

---Call registered callbacks
---@param event string: Event name
---@param data any: Event data
local function _emit(event, data)
  if _callbacks[event] then
    for _, cb in ipairs(_callbacks[event]) do
      cb(data)
    end
  end
end

---Create a new terminal session
---@param cmd string: Command to execute
---@return TerminalSession|nil: Created session or nil if failed
function M.create(cmd)
  if not cmd or cmd == "" then
    return nil
  end

  local id = _generate_id()

  -- Try to load Terminal, but allow graceful degradation for testing
  local terminal = nil
  local ok, Terminal = pcall(function()
    return require("plenary.terminal").Terminal
  end)

  if ok and Terminal then
    terminal = Terminal:new({
      cmd = cmd,
      on_exit = function()
        -- Cleanup when terminal exits
        M.close(id)
      end,
    })
  end

  local session = {
    id = id,
    cmd = cmd,
    terminal = terminal,
    created_at = os.time(),
  }

  _sessions[id] = session

  -- Set as active if it's the first session
  if not _active_session_id then
    _active_session_id = id
    _emit("on_active_changed", { id = id, session = session })
  else
    _active_session_id = id
    _emit("on_active_changed", { id = id, session = session })
  end

  _emit("on_session_created", { id = id, session = session })

  return session
end

---List all active sessions
---@return TerminalSession[]
function M.list()
  local sessions = {}
  for _, session in pairs(_sessions) do
    table.insert(sessions, session)
  end
  table.sort(sessions, function(a, b)
    return a.created_at < b.created_at
  end)
  return sessions
end

---Get session by ID
---@param id string: Session ID
---@return TerminalSession|nil
function M.get_by_id(id)
  return _sessions[id]
end

---Get currently active session
---@return TerminalSession|nil
function M.get_active()
  if _active_session_id then
    return _sessions[_active_session_id]
  end
  return nil
end

---Get active session ID
---@return string|nil
function M.get_active_id()
  return _active_session_id
end

---Switch to a different session
---@param id string: Session ID to switch to
---@return boolean: True if successful, false if session not found
function M.switch(id)
  if not _sessions[id] then
    return false
  end

  _active_session_id = id
  _emit("on_active_changed", { id = id, session = _sessions[id] })
  return true
end

---Close a session
---@param id string: Session ID to close
---@return boolean: True if successful, false if session not found
function M.close(id)
  local session = _sessions[id]
  if not session then
    return false
  end

  -- Terminate the terminal if it exists
  if session.terminal then
    pcall(function()
      session.terminal:shutdown()
    end)
  end

  _sessions[id] = nil
  _emit("on_session_closed", { id = id })

  -- If closed session was active, switch to another
  if _active_session_id == id then
    local remaining = M.list()
    if #remaining > 0 then
      M.switch(remaining[1].id)
    else
      _active_session_id = nil
    end
  end

  return true
end

---Clear all sessions
function M.clear_all()
  for id in pairs(_sessions) do
    pcall(function()
      local session = _sessions[id]
      if session.terminal then
        session.terminal:shutdown()
      end
    end)
  end
  _sessions = {}
  _active_session_id = nil
  _session_counter = 0
end

---Check if session exists
---@param id string: Session ID
---@return boolean
function M.exists(id)
  return _sessions[id] ~= nil
end

---Register callback for session events
---@param event string: Event name (on_session_created, on_session_closed, on_active_changed)
---@param callback function: Callback function
function M.on(event, callback)
  if not _callbacks[event] then
    _callbacks[event] = {}
  end
  table.insert(_callbacks[event], callback)
end

return M
