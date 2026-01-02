# Task Breakdown: Theme Support

## Overview
Total Tasks: 4 Task Groups, 21 Sub-tasks

This feature adds manual theme control to Markdown Viewer, allowing users to override system appearance with forced Light or Dark themes via a View > Appearance submenu and Cmd+Shift+T keyboard shortcut.

## Task List

### Data Layer

#### Task Group 1: Appearance Model and Settings Manager
**Dependencies:** None

- [x] 1.0 Complete appearance data layer
  - [x] 1.1 Write 3-5 focused tests for AppearanceManager functionality
    - Test default preference is `.system` on fresh install
    - Test `cyclePreference()` cycles correctly: system -> light -> dark -> system
    - Test preference persists to UserDefaults after setting
    - Test preference loads correctly from UserDefaults on init
  - [x] 1.2 Create AppearancePreference enum
    - Cases: `system`, `light`, `dark` with String raw values
    - Add `next` computed property for cycling logic
    - Conform to `CaseIterable` for menu iteration
  - [x] 1.3 Create AppearanceManager class
    - Singleton pattern with `static let shared`
    - `@Published var preference` for SwiftUI observation
    - UserDefaults storage with key `appearancePreference`
    - `cyclePreference()` method for keyboard shortcut
  - [x] 1.4 Ensure data layer tests pass
    - Run ONLY the 3-5 tests written in 1.1
    - Verify UserDefaults persistence works correctly

**Acceptance Criteria:**
- The 3-5 tests written in 1.1 pass
- AppearancePreference enum correctly cycles through states
- AppearanceManager persists and loads preferences from UserDefaults
- Default preference is `.system` for new users

### CSS/JavaScript Layer

#### Task Group 2: WebView Theme Support
**Dependencies:** Task Group 1

- [x] 2.0 Complete WebView theme integration
  - [x] 2.1 Write 2-4 focused tests for theme application
    - Test `applyTheme('light')` JavaScript sets correct meta tag content
    - Test `applyTheme('dark')` JavaScript adds correct class to html element
    - Test `applyTheme('system')` JavaScript restores default behavior
  - [x] 2.2 Add color-scheme meta tag to HTML template
    - Add `<meta name="color-scheme" content="light dark" id="colorSchemeTag">` to head
    - Position in existing `wrapInHTML()` function
  - [x] 2.3 Add `applyTheme()` JavaScript function
    - Handle three cases: 'light', 'dark', 'system'
    - Modify meta tag content attribute
    - Add/remove theme classes on `<html>` element
  - [x] 2.4 Add forced theme CSS rules
    - Add `html.theme-light` styles for all themed elements
    - Add `html.theme-dark` styles for all themed elements
    - Ensure specificity overrides `@media (prefers-color-scheme)` queries
    - Elements: body, a, code, pre, blockquote, table, hr, headings
  - [x] 2.5 Add Swift method to call JavaScript
    - Create `applyAppearance(_:preference:)` method
    - Use `evaluateJavaScript()` to call `applyTheme()`
  - [x] 2.6 Ensure WebView theme tests pass
    - Run ONLY the 2-4 tests written in 2.1
    - Verify JavaScript function works correctly

**Acceptance Criteria:**
- The 2-4 tests written in 2.1 pass
- Forced themes override system appearance detection
- Theme changes apply without page reload
- CSS specificity correctly overrides media queries

### Menu Layer

#### Task Group 3: Menu UI and Keyboard Shortcut
**Dependencies:** Task Group 1

- [x] 3.0 Complete menu implementation
  - [x] 3.1 Write 2-4 focused tests for menu functionality
    - Test menu Picker binding updates AppearanceManager preference
    - Test cycle shortcut action calls `cyclePreference()`
    - Test menu reflects current preference state
  - [x] 3.2 Add AppearanceManager to MarkdownViewerApp
    - Add `@StateObject` for AppearanceManager.shared
    - Pass through environment to child views
  - [x] 3.3 Create View > Appearance submenu
    - Add `CommandGroup(after: .toolbar)` to commands modifier
    - Use `Picker` with `.inline` style for checkmark behavior
    - Three options: System, Light, Dark
  - [x] 3.4 Add Cycle Appearance menu item with keyboard shortcut
    - Menu item text: "Cycle Appearance"
    - Keyboard shortcut: Cmd+Shift+T
    - Action calls `appearanceManager.cyclePreference()`
  - [x] 3.5 Ensure menu tests pass
    - Run ONLY the 2-4 tests written in 3.1
    - Verify menu items appear correctly

**Acceptance Criteria:**
- The 2-4 tests written in 3.1 pass
- View > Appearance submenu appears with three options
- Checkmark indicates current selection
- Cmd+Shift+T cycles through options correctly

### Integration Layer

#### Task Group 4: WebView-AppearanceManager Integration
**Dependencies:** Task Groups 1, 2, 3

- [x] 4.0 Complete integration and test review
  - [x] 4.1 Write 2-4 focused integration tests
    - Test WebView applies theme on initial content load
    - Test WebView updates theme when preference changes
    - Test new window inherits current preference
    - Test multiple windows update simultaneously
  - [x] 4.2 Add EnvironmentObject to WebView
    - Add `@EnvironmentObject var appearanceManager: AppearanceManager`
    - Update Coordinator to track last applied appearance
  - [x] 4.3 Apply theme on content load
    - Add callback in Coordinator for load completion
    - Call `applyAppearance()` when content finishes loading
  - [x] 4.4 Observe preference changes in updateNSView
    - Compare current preference with coordinator's last applied
    - Call `applyAppearance()` when preference differs
    - Update coordinator's tracked preference
  - [x] 4.5 Pass environment through ContentView
    - Ensure `.environmentObject(appearanceManager)` flows to WebView
    - Verify environment propagates to all windows
  - [x] 4.6 Review all tests and fill critical gaps
    - Review tests from Task Groups 1-3 (approximately 7-13 tests)
    - Add up to 5 additional tests for end-to-end workflows if needed
    - Focus on multi-window behavior and persistence across launches
  - [x] 4.7 Run all feature-specific tests
    - Run all tests written for this feature
    - Verify theme changes apply instantly
    - Verify persistence survives app restart

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 12-20 tests total)
- Theme changes apply to all open windows simultaneously
- New windows inherit current preference
- Preference persists across app launches
- No flicker or delay when switching themes

## Execution Order

Recommended implementation sequence:

1. **Data Layer (Task Group 1)** - Foundation for preference storage
   - Creates AppearancePreference enum and AppearanceManager class
   - Establishes UserDefaults pattern for future settings

2. **CSS/JavaScript Layer (Task Group 2)** - Theme rendering capability
   - Depends on knowing the preference values from Task Group 1
   - Adds forced theme CSS and JavaScript bridge

3. **Menu Layer (Task Group 3)** - User interface
   - Depends on AppearanceManager from Task Group 1
   - Can run in parallel with Task Group 2

4. **Integration Layer (Task Group 4)** - Connect all pieces
   - Depends on all previous groups
   - Wires WebView to observe AppearanceManager changes
   - Final testing and gap analysis

## Notes

- Task Groups 2 and 3 can potentially be worked in parallel since they both depend only on Task Group 1
- This is the first UserDefaults usage in the app, establishing patterns for future settings
- No backend/API layer needed - this is a purely client-side feature
- Manual testing checklist is provided in the spec for UI verification
