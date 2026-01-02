# Spec: Theme Support

## Overview

Add manual theme control to Markdown Viewer, allowing users to override the automatic system appearance with a forced Light or Dark theme. The feature provides a View > Appearance submenu with three options (System, Light, Dark) and a keyboard shortcut (Cmd+Shift+T) to cycle through them.

## Background

### Current State
- WebView.swift contains CSS with `@media (prefers-color-scheme: dark)` media queries
- Theme automatically follows macOS system appearance
- No user preference storage exists yet (this is the first UserDefaults feature)
- No custom menus exist yet (SwiftUI DocumentGroup provides default menus)

### Problem
Users cannot override the system theme when viewing markdown. Sometimes you want to force light mode for better readability in bright environments, or dark mode to reduce eye strain, regardless of system settings.

## Requirements

### Functional Requirements

1. **Three Theme States**
   - System (default): follows macOS appearance automatically
   - Light: forces light theme regardless of system setting
   - Dark: forces dark theme regardless of system setting

2. **Menu Interface**
   - Location: View > Appearance (submenu)
   - Three menu items: System, Light, Dark
   - Checkmark indicates current selection
   - Standard macOS submenu behavior

3. **Keyboard Shortcut**
   - Cmd+Shift+T cycles through options: System -> Light -> Dark -> System
   - Shortcut works regardless of which submenu item has focus

4. **Persistence**
   - Theme preference persists across app launches
   - Storage: UserDefaults with key `appearancePreference`
   - Default value: `system` (for new users)

5. **Application Behavior**
   - Theme changes apply instantly (no animation)
   - Global preference applies to all open windows
   - New windows inherit current preference

### Out of Scope
- Per-document theme overrides
- Time-based/scheduled theme switching
- Transition animations
- Custom color themes beyond light/dark

## Technical Design

### Data Model

```swift
/// Represents the user's appearance preference
enum AppearancePreference: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    /// Returns the next preference in the cycle
    var next: AppearancePreference {
        switch self {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }
}
```

### Settings Manager

Create a new `AppearanceManager` class to handle preference storage and notifications:

```swift
/// Manages appearance preference storage and change notifications
class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()

    private let key = "appearancePreference"

    @Published var preference: AppearancePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: key)
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: key) ?? "system"
        self.preference = AppearancePreference(rawValue: stored) ?? .system
    }

    func cyclePreference() {
        preference = preference.next
    }
}
```

### CSS Strategy

The current CSS uses `@media (prefers-color-scheme: dark)` which responds to system settings. To override this:

1. **Add a `color-scheme` meta tag** that can be updated dynamically
2. **Add a root-level class** (`theme-light` or `theme-dark`) when forcing a theme
3. **Duplicate theme-specific styles** under these classes (in addition to media queries)

#### HTML Changes

Add to the `<head>` section:
```html
<meta name="color-scheme" content="light dark" id="colorSchemeTag">
```

Add JavaScript function to apply theme:
```javascript
function applyTheme(preference) {
    const meta = document.getElementById('colorSchemeTag');
    const root = document.documentElement;

    // Remove existing theme classes
    root.classList.remove('theme-light', 'theme-dark', 'theme-system');

    switch(preference) {
        case 'light':
            meta.content = 'light';
            root.classList.add('theme-light');
            break;
        case 'dark':
            meta.content = 'dark';
            root.classList.add('theme-dark');
            break;
        default: // system
            meta.content = 'light dark';
            root.classList.add('theme-system');
            break;
    }
}
```

#### CSS Changes

Add forced theme rules that override media queries:

```css
/* Forced light theme */
html.theme-light body {
    background-color: #ffffff;
    color: #1f2328;
}
html.theme-light a { color: #0969da; }
html.theme-light code { background-color: #f6f8fa; }
html.theme-light pre { background-color: #f6f8fa; }
html.theme-light blockquote { border-left-color: #d0d7de; color: #656d76; }
html.theme-light table th, html.theme-light table td { border-color: #d0d7de; }
html.theme-light table tr:nth-child(2n) { background-color: #f6f8fa; }
html.theme-light table th { background-color: #f6f8fa; }
html.theme-light hr { background-color: #d0d7de; }
html.theme-light h1, html.theme-light h2 { border-bottom-color: #d0d7de; }
html.theme-light h6 { color: #656d76; }

/* Forced dark theme */
html.theme-dark body {
    background-color: #1e1e1e;
    color: #d4d4d4;
}
html.theme-dark a { color: #58a6ff; }
html.theme-dark code { background-color: #2d2d2d; }
html.theme-dark pre { background-color: #2d2d2d; }
html.theme-dark blockquote { border-left-color: #444; color: #999; }
html.theme-dark table th, html.theme-dark table td { border-color: #444; }
html.theme-dark table tr:nth-child(2n) { background-color: #2d2d2d; }
html.theme-dark table th { background-color: #2d2d2d; }
html.theme-dark hr { background-color: #444; }
html.theme-dark h1, html.theme-dark h2 { border-bottom-color: #444; }
html.theme-dark h6 { color: #999; }
```

### Swift-to-JavaScript Bridge

WebView needs to call `applyTheme()` when:
1. Initial page load (read from AppearanceManager)
2. Preference changes (observe AppearanceManager.preference)

Add to WebView.swift:

```swift
/// Applies the current appearance preference to the web view
func applyAppearance(_ webView: WKWebView, preference: AppearancePreference) {
    let js = "applyTheme('\(preference.rawValue)');"
    webView.evaluateJavaScript(js, completionHandler: nil)
}
```

### Menu Implementation

Add commands to MarkdownViewerApp.swift:

```swift
@main
struct MarkdownViewerApp: App {
    @StateObject private var appearanceManager = AppearanceManager.shared

    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            ContentView(document: file.$document, fileURL: file.fileURL)
                .environmentObject(appearanceManager)
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(after: .toolbar) {
                Menu("Appearance") {
                    Button("System") {
                        appearanceManager.preference = .system
                    }
                    .keyboardShortcut(appearanceManager.preference == .system ? nil : nil)
                    // Checkmark via toggle or custom view

                    Button("Light") {
                        appearanceManager.preference = .light
                    }

                    Button("Dark") {
                        appearanceManager.preference = .dark
                    }
                }

                Divider()

                Button("Toggle Appearance") {
                    appearanceManager.cyclePreference()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}
```

Note: SwiftUI's standard `Button` in menus does not directly support checkmarks. Implementation options:
1. Use `Toggle` with custom styling
2. Use picker-style menu
3. Prefix with checkmark character in title

Recommended approach using Picker:

```swift
CommandGroup(after: .toolbar) {
    Picker("Appearance", selection: $appearanceManager.preference) {
        Text("System").tag(AppearancePreference.system)
        Text("Light").tag(AppearancePreference.light)
        Text("Dark").tag(AppearancePreference.dark)
    }
    .pickerStyle(.inline)

    Divider()

    Button("Cycle Appearance") {
        appearanceManager.cyclePreference()
    }
    .keyboardShortcut("t", modifiers: [.command, .shift])
}
```

### WebView Integration

Update WebView to observe appearance changes:

```swift
struct WebView: NSViewRepresentable {
    let content: String
    let fileURL: URL?
    @EnvironmentObject var appearanceManager: AppearanceManager

    // ... existing code ...

    func makeNSView(context: Context) -> WKWebView {
        // ... existing setup ...

        // Apply initial appearance after content loads
        context.coordinator.onLoadComplete = { webView in
            self.applyAppearance(webView, preference: self.appearanceManager.preference)
        }

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Handle content changes (existing)
        if content != context.coordinator.lastContent {
            context.coordinator.lastContent = content
            let html = wrapInHTML(content)
            let baseURL = fileURL?.deletingLastPathComponent()
            nsView.loadHTMLString(html, baseURL: baseURL)
        }

        // Handle appearance changes
        if appearanceManager.preference != context.coordinator.lastAppearance {
            context.coordinator.lastAppearance = appearanceManager.preference
            applyAppearance(nsView, preference: appearanceManager.preference)
        }
    }
}
```

## File Changes

### New Files
- `AppearanceManager.swift`: Preference management class
- `AppearancePreference.swift`: Enum definition (or include in AppearanceManager)

### Modified Files
- `WebView.swift`:
  - Add CSS for forced themes
  - Add `applyTheme()` JavaScript function
  - Add `color-scheme` meta tag
  - Observe AppearanceManager for changes
  - Call JavaScript on preference change

- `MarkdownViewerApp.swift`:
  - Add AppearanceManager as @StateObject
  - Add View > Appearance menu with Picker
  - Add Cycle Appearance menu item with Cmd+Shift+T
  - Pass appearanceManager to ContentView via environment

- `ContentView.swift`:
  - Pass appearanceManager to WebView via environment (if needed)

## Testing

### Manual Testing Checklist

1. **Default Behavior**
   - [ ] Fresh install defaults to System
   - [ ] System mode follows macOS appearance changes

2. **Menu Functionality**
   - [ ] View > Appearance submenu appears
   - [ ] Three options visible: System, Light, Dark
   - [ ] Checkmark appears on current selection
   - [ ] Clicking option changes theme immediately

3. **Keyboard Shortcut**
   - [ ] Cmd+Shift+T cycles: System -> Light -> Dark -> System
   - [ ] Shortcut works from any context

4. **Persistence**
   - [ ] Quit and relaunch preserves preference
   - [ ] Preference survives system restart

5. **Multi-Window**
   - [ ] Theme change affects all open windows
   - [ ] New window opens with current preference

6. **Edge Cases**
   - [ ] Rapid theme switching does not cause flicker/crash
   - [ ] Works correctly after file reload
   - [ ] Works correctly after opening new document

### Unit Tests

```swift
// AppearanceManagerTests.swift
func testDefaultPreference() {
    UserDefaults.standard.removeObject(forKey: "appearancePreference")
    let manager = AppearanceManager()
    XCTAssertEqual(manager.preference, .system)
}

func testCyclePreference() {
    let manager = AppearanceManager()
    manager.preference = .system

    manager.cyclePreference()
    XCTAssertEqual(manager.preference, .light)

    manager.cyclePreference()
    XCTAssertEqual(manager.preference, .dark)

    manager.cyclePreference()
    XCTAssertEqual(manager.preference, .system)
}

func testPersistence() {
    let manager = AppearanceManager()
    manager.preference = .dark

    // Simulate app restart
    let newManager = AppearanceManager()
    XCTAssertEqual(newManager.preference, .dark)
}
```

## Implementation Notes

### CSS Specificity
The forced theme CSS rules use `html.theme-*` selector which has higher specificity than the `@media` queries. This ensures forced themes override system detection.

### Performance
- JavaScript `applyTheme()` only modifies two DOM elements (meta tag and classList)
- No page reload required for theme changes
- CSS class toggle is instantaneous

### Future Considerations
- This establishes the UserDefaults pattern for future settings (typography, etc.)
- AppearanceManager could be extended or generalized to SettingsManager
- The JavaScript bridge pattern can be reused for other settings that affect rendering
