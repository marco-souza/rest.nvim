local terminal_manager = require("term.utils.terminal")

local M = {}

function M.test_create_session()
  terminal_manager.clear_all()
  local session = terminal_manager.create("echo test")
  assert(session ~= nil, "Session should not be nil")
  assert(session.id ~= nil, "Session ID should not be nil")
  assert(session.cmd == "echo test", "Session cmd should match")
end

function M.test_create_empty_command()
  terminal_manager.clear_all()
  local session = terminal_manager.create("")
  assert(session == nil, "Empty command should return nil")
end

function M.test_create_nil_command()
  terminal_manager.clear_all()
  local session = terminal_manager.create(nil)
  assert(session == nil, "Nil command should return nil")
end

function M.test_list_sessions()
  terminal_manager.clear_all()
  terminal_manager.create("cmd1")
  terminal_manager.create("cmd2")
  terminal_manager.create("cmd3")
  local sessions = terminal_manager.list()
  assert(#sessions == 3, "Should have 3 sessions")
end

function M.test_list_empty()
  terminal_manager.clear_all()
  local sessions = terminal_manager.list()
  assert(#sessions == 0, "Should have 0 sessions")
end

function M.test_get_active()
  terminal_manager.clear_all()
  local session = terminal_manager.create("test")
  local active = terminal_manager.get_active()
  assert(active ~= nil, "Active session should not be nil")
  assert(active.id == session.id, "Active session ID should match")
end

function M.test_get_active_empty()
  terminal_manager.clear_all()
  local active = terminal_manager.get_active()
  assert(active == nil, "Active session should be nil when empty")
end

function M.test_switch_session()
  terminal_manager.clear_all()
  local s1 = terminal_manager.create("cmd1")
  terminal_manager.create("cmd2")
  terminal_manager.switch(s1.id)
  local active = terminal_manager.get_active()
  assert(active.id == s1.id, "Active session should be s1")
end

function M.test_switch_invalid()
  terminal_manager.clear_all()
  local result = terminal_manager.switch("invalid-id")
  assert(result == false, "Switch should return false for invalid ID")
end

function M.test_close_session()
  terminal_manager.clear_all()
  local session = terminal_manager.create("echo test")
  terminal_manager.close(session.id)
  local sessions = terminal_manager.list()
  assert(#sessions == 0, "Session should be removed")
end

function M.test_close_active_switches_to_other()
  terminal_manager.clear_all()
  local s1 = terminal_manager.create("cmd1")
  local s2 = terminal_manager.create("cmd2")
  terminal_manager.close(s2.id)
  local active = terminal_manager.get_active()
  assert(active.id == s1.id, "Active should switch to s1")
end

function M.test_close_last_clears_active()
  terminal_manager.clear_all()
  local session = terminal_manager.create("cmd")
  terminal_manager.close(session.id)
  local active = terminal_manager.get_active()
  assert(active == nil, "Active should be nil")
end

function M.test_close_invalid()
  terminal_manager.clear_all()
  local result = terminal_manager.close("invalid-id")
  assert(result == false, "Close should return false for invalid ID")
end

function M.test_get_by_id()
  terminal_manager.clear_all()
  local created = terminal_manager.create("echo test")
  local session = terminal_manager.get_by_id(created.id)
  assert(session ~= nil, "Session should be found")
  assert(session.id == created.id, "Session ID should match")
end

function M.test_get_by_id_invalid()
  terminal_manager.clear_all()
  local session = terminal_manager.get_by_id("invalid-id")
  assert(session == nil, "Invalid ID should return nil")
end

function M.test_clear_all()
  terminal_manager.clear_all()
  terminal_manager.create("cmd1")
  terminal_manager.create("cmd2")
  terminal_manager.clear_all()
  local sessions = terminal_manager.list()
  assert(#sessions == 0, "All sessions should be cleared")
end

function M.test_unique_ids()
  terminal_manager.clear_all()
  local s1 = terminal_manager.create("cmd1")
  local s2 = terminal_manager.create("cmd2")
  assert(s1.id ~= s2.id, "Session IDs should be unique")
end

return M
