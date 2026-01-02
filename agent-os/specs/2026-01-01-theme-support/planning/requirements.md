# Spec Requirements: Theme Support

## Initial Description
Add light/dark theme toggle, persist preference in UserDefaults, respect system appearance as default, implement View > Toggle Theme menu item and Cmd+Shift+T shortcut. This is for a macOS Markdown Viewer app built with SwiftUI and WKWebView.

## Requirements Discussion

### First Round Questions

**Q1:** When cycling through themes, should the menu item show the current state ("Theme: System") or the next action ("Switch to Light")? I'm assuming showing the current state with a submenu or label indicator is cleaner.
**Answer:** Use a submenu approach - View > Appearance with three options (System, Light, Dark), each with checkmark for current selection. This is more discoverable.

**Q2:** When the user toggles the theme, should there be any transition animation (brief fade), or should it switch instantly? I'm assuming instant is fine for a utility app.
**Answer:** Instant switch, no animation needed.

**Q3:** I'm assuming a submenu approach with three options (System, Light, Dark) each with a checkmark indicator would be more discoverable than cycling. Is that acceptable, or do you specifically want a single "Toggle Theme" item that cycles?
**Answer:** Yes, submenu with checkmarks. Keep Cmd+Shift+T as shortcut that cycles through the options.

**Q4:** Are there any edge cases you want to explicitly leave out for now (e.g., per-document theme overrides, theme scheduling based on time of day)?
**Answer:** No per-document overrides, no time-based scheduling. Simple global preference only.

### Existing Code to Reference

**Similar Features Identified:**
- Feature: CSS dark mode styles - Path: `WebView.swift` (contains `@media (prefers-color-scheme: dark)` blocks)
- Components to potentially reuse: Existing CSS light/dark styles already defined
- Backend logic to reference: None (this is the first UserDefaults usage)

**Notes:**
- No existing UserDefaults usage yet - this will be the first
- No existing custom menus yet - SwiftUI's DocumentGroup provides default menus
- Standard macOS menu patterns to follow

### Follow-up Questions
None needed - requirements are clear.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
Standard macOS menu patterns - no custom visuals needed.

## Requirements Summary

### Functional Requirements
- Three theme states: System (default), Light, Dark
- System mode follows macOS appearance automatically
- Light/Dark modes force the respective appearance regardless of system setting
- Theme preference persists across app launches via UserDefaults
- View > Appearance submenu with System, Light, Dark options
- Checkmark indicator shows current selection in menu
- Cmd+Shift+T keyboard shortcut cycles through options (System -> Light -> Dark -> System)
- Theme changes apply instantly (no animation)
- Theme affects WKWebView rendered content by overriding CSS color scheme

### Reusability Opportunities
- Existing CSS in WebView.swift already has light and dark styles via `@media (prefers-color-scheme: dark)`
- Need to force one or the other when not in "System" mode
- This establishes the first UserDefaults pattern for future settings

### Scope Boundaries
**In Scope:**
- Global theme preference (applies to all windows)
- Three-state toggle (System, Light, Dark)
- Menu with submenu and checkmarks
- Keyboard shortcut for cycling
- UserDefaults persistence
- Instant theme switching in WKWebView

**Out of Scope:**
- Per-document theme overrides
- Time-based/scheduled theme switching
- Transition animations
- Theme customization beyond light/dark

### Technical Considerations
- SwiftUI app using DocumentGroup for window management
- WKWebView renders markdown content with embedded CSS
- Current CSS uses `@media (prefers-color-scheme: dark)` for automatic theme
- Need JavaScript bridge or CSS override mechanism to force light/dark
- UserDefaults key: "themePreference" (or similar)
- Must work with multiple windows (global preference applies to all)
