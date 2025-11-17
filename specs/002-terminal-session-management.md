# Terminal Session Management Specification

**Status:** In Review  
**Author:** @marco-souza  
**Date:** 2025-11-17  
**Last Updated:** 2025-11-17

## Overview

### Problem Statement
Users need to manage multiple terminal sessions within Neovim with an intuitive interface. Currently, the plugin has UI scaffolding but lacks the core functionality to create, switch, and manage terminal sessions. Users should be able to spawn terminal commands, view active sessions, switch between them, and close them.

### Success Criteria
- [ ] Users can create a new terminal session with `:Term <cmd>`
- [ ] Users can view all active terminal sessions in the left panel
- [ ] Users can switch between terminal sessions by selecting from the list
- [ ] Users can close individual terminal sessions
- [ ] Terminal output persists while dashboard is closed
- [ ] Keybindings work for navigation and session management

## User Journeys

### Journey 1: User creates and manages multiple terminal sessions
```
Given the user is in Neovim
When the user runs :Term "npm start"
Then a new terminal session is created and displayed in the right panel
And the session appears in the left panel list
And the session is marked as active (highlighted)

When the user runs :Term "watch" in another split
Then a second session is created
And both sessions appear in the left panel
And the user can switch between them with j/k and Enter

When the user presses 'd' on a session in the left panel
Then that session is terminated
And it's removed from the list
And if it was active, the next session becomes active
```

### Journey 2: User closes and reopens dashboard without losing sessions
```
Given the user has active terminal sessions
When the user presses 'q' to close the dashboard
Then the sessions continue running in the background
And the dashboard is hidden

When the user runs :Term again
Then the dashboard reopens
And all previously active sessions are still listed
And their output is preserved
```

## Functional Requirements

### FR-1: Terminal Session Creation
**Description:** Users should be able to create new terminal sessions with custom commands.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] `:Term <cmd>` spawns a new terminal session
- [ ] Session is assigned a unique ID
- [ ] Session appears immediately in the left panel
- [ ] New session becomes the active terminal (right panel)
- [ ] Session stores the command for reference

### FR-2: Terminal Session Listing
**Description:** The dashboard left panel displays all active terminal sessions.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] Left panel shows all active sessions with their commands
- [ ] Current active session is highlighted
- [ ] Sessions are numbered or labeled for easy identification
- [ ] Panel updates when sessions are created/closed

### FR-3: Session Switching
**Description:** Users can navigate and switch between terminal sessions.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] `j/k` in left panel moves cursor up/down through sessions
- [ ] `<CR>` (Enter) switches to the selected session
- [ ] Right panel displays the selected session's terminal
- [ ] Active session is visually highlighted in left panel

### FR-4: Session Closure
**Description:** Users can close individual terminal sessions.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] `d` in left panel closes the selected session
- [ ] Session process is terminated gracefully
- [ ] Session is removed from the left panel immediately
- [ ] If active session is closed, another session becomes active

### FR-5: Terminal Output Display
**Description:** Right panel displays full terminal emulation with command output.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] Terminal output is rendered in real-time
- [ ] User can interact with terminal (input/output)
- [ ] Scrolling works for viewing output history
- [ ] Terminal size adapts when dashboard is resized

### FR-6: Session Persistence
**Description:** Sessions persist even when the dashboard is closed.  
**Priority:** P0  
**Acceptance Criteria:**
- [ ] Sessions continue running when dashboard is closed
- [ ] Output is preserved for reattachment
- [ ] Dashboard can be reopened without losing state
- [ ] Sessions can be reattached by selecting from left panel

## Non-Functional Requirements

### Performance
- Session creation: < 100ms
- Dashboard render: < 50ms
- Session switching: instant (no noticeable lag)

### Reliability
- Graceful handling of process termination
- No memory leaks from long-running sessions
- Clean cleanup on plugin unload

### Compatibility
- Works with: Neovim 0.7.0+
- Tested on: macOS, Linux
- Terminal types: bash, zsh, fish, sh

## Edge Cases & Error Handling

### Edge Case 1: Command fails to execute
**Current behavior:** Session is created but process exits immediately.  
**Expected behavior:** Show error in right panel and remove from list after user dismisses.  
**Handling:** Detect process exit, display error message, allow user to acknowledge.

### Edge Case 2: Invalid command provided
**Current behavior:** Unknown.  
**Expected behavior:** Display error message without creating session.  
**Handling:** Validate command syntax before spawning process.

### Edge Case 3: All sessions are closed
**Current behavior:** Unknown.  
**Expected behavior:** Left panel shows "No terminals open", right panel is empty.  
**Handling:** Display placeholder text in both panels.

### Edge Case 4: Terminal window resized
**Current behavior:** Unknown.  
**Expected behavior:** Terminal output adapts to new window size.  
**Handling:** Hook into Neovim resize events, adjust terminal size accordingly.

### Edge Case 5: User closes Neovim with active sessions
**Current behavior:** Unknown.  
**Expected behavior:** Sessions are terminated cleanly.  
**Handling:** Register cleanup handler on Neovim exit.

## Technical Considerations

### Architecture Impact
- New module: `lua/term/utils/terminal.lua` - Session management
- Modified module: `lua/term/ui/dashboard.lua` - Display sessions and terminal
- Modified module: `lua/term/cmd.lua` - Route commands to session manager
- Dependencies: `plenary.nvim` (Terminal API), `nui.nvim` (UI)

### Implementation Notes

**Session Management (`utils/terminal.lua`):**
- Store sessions in a table: `{id -> {cmd, pid, pty, bufnr}}`
- Use `plenary.terminal.Terminal` for spawning processes
- Track active session globally
- Provide methods: `create()`, `list()`, `switch()`, `close()`, `get_active()`

**Dashboard Updates (`ui/dashboard.lua`):**
- Render session list from session manager
- Handle keybindings: `j/k` for navigation, `<CR>` to switch, `d` to close, `n` to create
- Display session commands and status in left panel
- Embed active terminal in right panel using `plenary.terminal.Terminal`
- Subscribe to session change events

**Command Routing (`cmd.lua`):**
- Route `:Term <cmd>` to `session_manager.create(cmd)`
- Route `:Term` to `dashboard.toggle()`
- Support `:Term list`, `:Term close`, `:Term switch`

### Testing Strategy
- Unit tests for session manager (create, list, switch, close)
- Integration tests for dashboard + session manager
- Manual testing: Multiple terminals, process termination, window resize
- Target: 80%+ coverage for utils/terminal.lua

## Dependencies

### Internal
- `lua/term/types.lua` - Type definitions
- `lua/term/ui/dashboard.lua` - UI layer
- `lua/term/cmd.lua` - Command interface

### External
- `plenary.nvim` (v0.1.0+) - Terminal spawning and process management
- `nui.nvim` (v0.4.0+) - UI components (Popup, Layout)

## Risks & Mitigations

### Risk 1: Process resource leaks
**Impact:** High  
**Likelihood:** Medium  
**Mitigation:** Implement proper cleanup handlers, test with many sessions, monitor memory usage.

### Risk 2: Terminal input/output conflicts
**Impact:** High  
**Likelihood:** Low  
**Mitigation:** Use `plenary.terminal.Terminal` abstraction, test with interactive programs (vim, less, etc).

### Risk 3: Window resize causing terminal corruption
**Impact:** Medium  
**Likelihood:** Medium  
**Mitigation:** Hook into resize events, test resizing during active terminal sessions.

### Risk 4: Session state inconsistency between panels
**Impact:** Medium  
**Likelihood:** Low  
**Mitigation:** Use event-driven architecture, subscribe to session changes, refresh UI on events.

## Open Questions

- [ ] Should sessions auto-restart on failure? - @marco-souza
- [ ] Should we support session naming? - @marco-souza
- [ ] Should we persist session history across Neovim restarts? - @marco-souza
- [ ] How should we handle environment variable substitution in commands? - @marco-souza

## Related Issues & References

- AGENTS.md - Terminal Session Lifecycle section
- GitHub Repo: https://github.com/marco-souza/term.nvim

## Sign-off

| Role | Name | Status |
|------|------|--------|
| Author | @marco-souza | ⏳ In Review |
| Reviewer 1 | - | ⏳ Pending |

## Implementation Checklist

Once approved, track implementation progress here:

- [ ] Technical Plan created
- [ ] `utils/terminal.lua` implemented
- [ ] Unit tests for terminal manager
- [ ] Dashboard integration with session list
- [ ] Keybindings implemented and tested
- [ ] Integration tests passing
- [ ] Manual testing complete
- [ ] Documentation updated
- [ ] PR created
