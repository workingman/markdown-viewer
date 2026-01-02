# Session Notes - Markdown Viewer

## Current Status
Completed 4 of 16 specs (MVP is 1-8).

**Completed:**
1. [x] Basic Window and File Opening
2. [x] Markdown Rendering (markdown-it integration)
3. [x] Styling and Typography (18px font)
4. [x] Theme Support (View > Appearance menu, Cmd+Shift+T)

**Next up:** Spec 5 - Internal Anchor Navigation

## Key Locations
- **Xcode project:** `/Users/gwr/Documents/dev/mdv/Markdown Viewer.xcodeproj`
- **Source files:** `/Users/gwr/Documents/dev/mdv/Markdown Viewer/`
- **Specs folder:** `agent-os/specs/`
- **Roadmap:** `agent-os/product/roadmap.md`

## Key Files
- `MarkdownViewerApp.swift` - App entry with DocumentGroup and View menu
- `MarkdownDocument.swift` - FileDocument for .md files
- `ContentView.swift` - Main view with WebView and drag-drop
- `WebView.swift` - WKWebView with markdown-it rendering, theme support
- `AppearanceManager.swift` - Theme preference (system/light/dark) with UserDefaults
- `Resources/js/` - Bundled markdown-it, anchor, task-lists JS

## Commands
- Build: `xcodebuild -project "Markdown Viewer.xcodeproj" -scheme "Markdown Viewer" build`
- Test: `xcodebuild -project "Markdown Viewer.xcodeproj" -scheme "Markdown Viewer" test`
- Clean build (after entitlements change): `xcodebuild ... clean build`

## Important Notes
- **Sandbox is DISABLED** - Required for DocumentGroup file access to work
- Entitlements changes require clean build
- 48 tests passing

## Learnings
See `SWIFTUI_LEARNINGS.md` for documented lessons (sandbox issues, entitlements, WKWebView patterns)
