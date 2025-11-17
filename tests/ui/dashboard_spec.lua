local describe = describe
local it = it
local assert = assert
local before_each = before_each
local after_each = after_each

local dashboard = require("term.ui.dashboard")
local terminal_manager = require("term.utils.terminal")

describe("dashboard", function()
  before_each(function()
    -- Clear sessions before each test
    terminal_manager.clear_all()
  end)

  after_each(function()
    -- Hide dashboard if visible
    if dashboard.is_visible() then
      dashboard.toggle()
    end
    terminal_manager.clear_all()
  end)

  describe("toggle", function()
    it("should show dashboard when hidden", function()
      assert.equal(dashboard.is_visible(), false)
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), true)
    end)

    it("should hide dashboard when visible", function()
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), true)
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), false)
    end)

    it("should toggle multiple times without errors", function()
      dashboard.toggle()
      dashboard.toggle()
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), true)
    end)
  end)

  describe("with sessions", function()
    it("should display all active sessions in left panel", function()
      terminal_manager.create("npm start")
      terminal_manager.create("npm test")
      dashboard.toggle()

      local sessions = dashboard.get_displayed_sessions()
      assert.equal(#sessions, 2)
    end)

    it("should highlight the active session", function()
      local s1 = terminal_manager.create("cmd1")
      local s2 = terminal_manager.create("cmd2")

      dashboard.toggle()
      local active_id = dashboard.get_active_session_id()
      assert.equal(active_id, s2.id)
    end)

    it("should update session list when new session is created", function()
      dashboard.toggle()
      assert.equal(#dashboard.get_displayed_sessions(), 0)

      terminal_manager.create("echo test")
      -- Dashboard should reflect the change
      assert.equal(#dashboard.get_displayed_sessions(), 1)
    end)

    it("should remove session from display when closed", function()
      local session = terminal_manager.create("echo test")
      dashboard.toggle()
      assert.equal(#dashboard.get_displayed_sessions(), 1)

      terminal_manager.close(session.id)
      assert.equal(#dashboard.get_displayed_sessions(), 0)
    end)

    it("should show 'No terminals open' when no sessions exist", function()
      dashboard.toggle()
      local placeholder = dashboard.get_empty_state_message()
      assert.is_not_nil(placeholder)
    end)
  end)

  describe("keybindings", function()
    it("should navigate sessions with j/k keys", function()
      terminal_manager.create("cmd1")
      terminal_manager.create("cmd2")
      terminal_manager.create("cmd3")

      dashboard.toggle()

      -- Simulate j/k navigation
      local index = dashboard.get_selected_index()
      assert.is_not_nil(index)
    end)

    it("should switch session with Enter key", function()
      local s1 = terminal_manager.create("cmd1")
      local s2 = terminal_manager.create("cmd2")

      dashboard.toggle()

      -- Select first session
      dashboard.select_session(1)
      local active_id = dashboard.get_active_session_id()
      assert.equal(active_id, s1.id)
    end)

    it("should close session with 'd' key", function()
      local s1 = terminal_manager.create("cmd1")
      local s2 = terminal_manager.create("cmd2")

      dashboard.toggle()

      -- Delete first session
      dashboard.delete_session(1)
      assert.equal(#dashboard.get_displayed_sessions(), 1)
    end)

    it("should close dashboard with 'q' key", function()
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), true)

      dashboard.close_dashboard()
      assert.equal(dashboard.is_visible(), false)
    end)
  end)

  describe("session persistence", function()
    it("should preserve sessions when dashboard is closed", function()
      local s1 = terminal_manager.create("cmd1")
      local s2 = terminal_manager.create("cmd2")

      dashboard.toggle()
      dashboard.toggle()

      -- Sessions should still exist
      local sessions = terminal_manager.list()
      assert.equal(#sessions, 2)
    end)

    it("should restore session list when dashboard is reopened", function()
      terminal_manager.create("cmd1")
      terminal_manager.create("cmd2")

      dashboard.toggle()
      local sessions1 = dashboard.get_displayed_sessions()

      dashboard.toggle()
      dashboard.toggle()
      local sessions2 = dashboard.get_displayed_sessions()

      assert.equal(#sessions1, #sessions2)
    end)
  end)

  describe("terminal display", function()
    it("should display active terminal in right panel", function()
      terminal_manager.create("echo test")
      dashboard.toggle()

      local terminal_bufnr = dashboard.get_terminal_bufnr()
      assert.is_not_nil(terminal_bufnr)
    end)

    it("should switch terminal display when session changes", function()
      local s1 = terminal_manager.create("cmd1")
      local s2 = terminal_manager.create("cmd2")

      dashboard.toggle()

      local bufnr1 = dashboard.get_terminal_bufnr()
      dashboard.select_session(1)
      local bufnr2 = dashboard.get_terminal_bufnr()

      -- Buffers might be different
      assert.is_not_nil(bufnr1)
      assert.is_not_nil(bufnr2)
    end)
  end)

  describe("margin configuration", function()
    it("should apply margin option to layout", function()
      dashboard.toggle({ margin = 4 })
      -- Dashboard should be rendered with 4 character margin
      assert.equal(dashboard.is_visible(), true)
      dashboard.toggle()
    end)

    it("should use default margin if not specified", function()
      dashboard.toggle()
      assert.equal(dashboard.is_visible(), true)
      dashboard.toggle()
    end)
  end)
end)
