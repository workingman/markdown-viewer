# Tech Stack

## Platform

- **Target OS:** macOS 13.0 (Ventura) or later
- **Architecture:** Universal binary (Apple Silicon and Intel)

## Languages

- **Swift:** Primary application language
- **JavaScript:** Embedded in WKWebView for markdown rendering and DOM manipulation
- **CSS:** Styling for rendered markdown content

## Frameworks

### Apple Frameworks
- **SwiftUI:** Application UI, windows, menus, settings
- **WebKit (WKWebView):** Markdown rendering surface, handles HTML/CSS/JS
- **AppKit:** File associations, system integration, window management
- **Foundation:** File system operations, UserDefaults, observers

### JavaScript Libraries (Embedded)
- **markdown-it v14:** Markdown parsing and HTML generation
- **markdown-it-anchor v9:** Automatic header ID generation with GitHub-style slugification

## Data Storage

- **UserDefaults:** User preferences (theme, typography settings, window positions)

## Testing

- **XCTest:** Unit testing framework for Swift code
- **XCUITest:** UI testing for application behavior and keyboard navigation

## Build and Development

- **Xcode:** IDE and build system
- **Swift Package Manager:** Dependency management (if needed for any Swift packages)

## Architecture Patterns

- **Document-based App:** Each window represents one open file
- **JavaScript Bridge:** Swift-to-JS communication for settings updates and scroll control
- **File Monitoring:** Polling-based file change detection for live reload
