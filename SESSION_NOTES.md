# Session Notes - Markdown Viewer

## Current Status
**MVP COMPLETE and deployed to /Applications!** 8 of 16 specs done.

**Completed (MVP):**
1. [x] Basic Window and File Opening
2. [x] Markdown Rendering (markdown-it integration)
3. [x] Styling and Typography (VS Code-like, 16px font, centered content)
4. [x] Theme Support (View > Appearance menu, Cmd+Shift+T)
5. [x] Internal Anchor Navigation (smooth scroll, highlight animation)
6. [x] Vi-Style Vertical Navigation (j/k, gg/G, Ctrl+d/u/f/b)
7. [x] Vi-Style Horizontal Navigation (h/l, 0/$)
8. [x] Vi-Style Search (/, n/N, Enter, Esc, match count)

**Next up:** Spec 9 - Live Reload (post-MVP)

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
- 70 tests passing

## Learnings
See `SWIFTUI_LEARNINGS.md` for documented lessons (sandbox issues, entitlements, WKWebView patterns)
