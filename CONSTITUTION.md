# term.nvim Constitution

This document establishes the **non-negotiable principles** that guide all development decisions for term.nvim. Every feature specification, technical plan, and implementation must respect these values.

## Core Values

### 1. Simplicity First
- **Value:** The plugin should be easy to understand and use
- **What this means:**
  - Keep command interface simple (`:Term <cmd>`)
  - Dashboard has two clear panels (sessions + terminal)
  - Sensible defaults, minimal configuration needed
  - Code is readable before it's clever
- **Decision Rule:** If a feature makes the plugin more complex, it needs strong justification
- **Examples:**
  ✅ Default margin of 2 characters (sensible default)  
  ✅ Single `:Term` command with subcommands  
  ❌ 10 configuration options for UI styling

### 2. Sessions Persist Across Views
- **Value:** Users' terminal sessions should never be lost when dashboard is closed
- **What this means:**
  - Closing dashboard (pressing `q`) keeps sessions alive
  - Reopening `:Term` shows all previous sessions
  - Session state/output is preserved in memory
  - No data loss unless user explicitly deletes session
- **Decision Rule:** Any feature that could affect session persistence needs explicit session lifecycle testing
- **Examples:**
  ✅ Store sessions in module-level state  
  ✅ Unmount UI without destroying sessions  
  ❌ Clear all sessions on dashboard close

### 3. Lazy Plugin Friendly
- **Value:** The plugin integrates smoothly with lazy.nvim
- **What this means:**
  - No plugin folder required (lazy handles it)
  - `require("term").setup()` is the entry point
  - Configuration via `opts` table in lazy config
  - Optional dependencies (`nui.nvim`, `plenary.nvim`) should fail gracefully
- **Decision Rule:** All setup patterns must work with lazy.nvim out of the box
- **Examples:**
  ✅ Setup function that accepts config table  
  ✅ Graceful error if `nui.nvim` not installed  
  ❌ Requiring plugin folder entry point

### 4. Type Safety & Documentation
- **Value:** Code is well-documented and types are explicit
- **What this means:**
  - All functions have `---@param` type comments
  - Shared types live in `lua/term/types.lua`
  - No magic numbers, all settings have defaults
  - Code readability is not negotiable
- **Decision Rule:** Code reviews must check for missing documentation
- **Examples:**
  ✅ `---@param opts TermOptions` with shared type  
  ✅ `_defaults` table at module level  
  ❌ `function do_something(x)` with no comments

### 5. Lua Code Style Compliance
- **Value:** Consistent code style across all files
- **What this means:**
  - Snake_case for functions/variables
  - PascalCase for class-like objects
  - Private functions prefixed with `_`
  - stylua formatting (80 char width, 2-space indent)
  - Max line length enforced at 80 characters
- **Decision Rule:** `make fmt` must pass before PR can be merged
- **Examples:**
  ✅ `local function _internal_helper()` (private)  
  ✅ `local function toggle_dashboard()` (public)  
  ❌ `local function ToggleDashboard()` (wrong case)

### 6. Testing is Part of Done
- **Value:** Features are tested before merged
- **What this means:**
  - Unit tests for core logic
  - Tests live in `lua/tests/` mirroring source structure
  - Test command: `make test` (headless nvim)
  - Code changes require corresponding test updates
- **Decision Rule:** Don't merge features without tests
- **Examples:**
  ✅ Test session creation/switching/deletion  
  ✅ Test config merging with defaults  
  ❌ Skip tests for "UI is hard to test"

### 7. Neovim Compatibility
- **Value:** The plugin works with supported Neovim versions
- **What this means:**
  - Minimum version: Neovim 0.5.0
  - Use standard Neovim APIs (`vim.api.*`)
  - Don't rely on undocumented or deprecated APIs
  - Test on macOS, Linux, and Windows (WSL)
- **Decision Rule:** Feature needs to work across all platforms
- **Examples:**
  ✅ Use `vim.tbl_deep_extend` for config merging  
  ❌ Use platform-specific shell commands without fallback

## Governance

### Changes to Constitution
- Any developer can propose changes
- Requires discussion in pull request
- Changes should be documented with clear rationale
- Constitution updates are reviewed at same level as feature specs

### Enforcement
- Code reviews check constitution compliance
- `make lint` helps catch style violations
- Test failures block merges
- Spec reviews validate alignment with principles

### When Principles Conflict
If two principles conflict in a feature:
1. Document the conflict explicitly
2. Discuss with team
3. Update constitution or spec to clarify
4. Never silently ignore a principle

## Examples in Action

### Example 1: Adding a New Config Option

**Proposal:** Add `ui.border_style = "rounded" | "single"` config

**Evaluation:**
- ✅ Aligns with "Simplicity First"? ⚠️ Partial - adds config complexity
- ✅ Preserves session persistence? ✅ Yes
- ✅ Lazy.nvim friendly? ✅ Yes
- ✅ Type safe? ✅ Need to add to `TermOptions`
- ✅ Code style? ✅ If implemented correctly
- ✅ Tested? ⚠️ Need UI tests
- ✅ Neovim compatible? ✅ Yes

**Verdict:** Approve, but requires UI test coverage and type definition

### Example 2: Clearing Sessions on Dashboard Close

**Proposal:** Delete all sessions when user closes dashboard

**Evaluation:**
- ✅ Aligns with "Simplicity First"? ⚠️ Yes, simpler state management
- ✅ Preserves session persistence? ❌ **NO** - violates core value
- ✅ Lazy.nvim friendly? ✅ Yes
- ✅ Type safe? ✅ Yes
- ✅ Code style? ✅ Yes
- ✅ Tested? ⚠️ Could be
- ✅ Neovim compatible? ✅ Yes

**Verdict:** Reject - violates "Sessions Persist Across Views" principle

## Quick Reference

| Principle | Key Takeaway |
|-----------|--------------|
| Simplicity | Keep it simple, config-lite |
| Persistence | Sessions live beyond UI |
| lazy.nvim | No plugin/ folder needed |
| Types | Explicit, documented, shared |
| Style | snake_case, 80 chars, 2-space indent |
| Testing | Tests are required, not optional |
| Compatibility | Works on all supported platforms |

---

**Last Updated:** 2025-11-17  
**Maintained By:** term.nvim development team
