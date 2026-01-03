# Product Roadmap

1. [x] Basic Window and File Opening — Create main window with WKWebView, implement File > Open and drag-and-drop file opening, display filename in window title `M`

2. [x] Markdown Rendering — Integrate markdown-it with markdown-it-anchor plugin, render GitHub-flavored markdown with full syntax support (headers, lists, code blocks, tables, task lists, blockquotes, links, images) `M`

3. [x] Styling and Typography — Implement GitHub-style CSS, apply default typography settings (18px font, line height, max content width), ensure responsive layout `S`

4. [x] Theme Support — Add light/dark theme toggle, persist preference in UserDefaults, respect system appearance as default, implement View > Toggle Theme menu item and Cmd+Shift+T shortcut `S`

5. [x] Internal Anchor Navigation — Enable internal anchor links to scroll to targets, implement animated highlighting on jump, add smart scrolling (instant for long distances, smooth for short) `S`

6. [x] Vi-Style Vertical Navigation — Implement j/k scrolling, gg/G for top/bottom, Ctrl+d/u for half-page, Ctrl+f/b for full-page scrolling with smart scroll behavior `M`

7. [x] Vi-Style Horizontal Navigation — Implement h/l scrolling, 0/$ for far left/right navigation `S`

8. [x] Vi-Style Search — Implement / to open search box, real-time highlighting, n/N for next/previous match, Enter/Shift+Enter to jump and close, Esc to cancel, match count display `M`

9. [ ] Live Reload — Monitor open file for changes with 1-second polling, auto re-render on modification, preserve scroll position during reload `S`

10. [ ] File Associations — Register as handler for .md and .markdown files, configure UTI for net.daringfireball.markdown, appear in Open With menu `S`

11. [ ] Multiple Windows — Support multiple open windows (one file per window), implement File > New Window, File > Close, remember window size/position per file `M`

12. [ ] Menu Structure — Implement complete menu bar (File, Edit, View, Window, Help) with all keyboard shortcuts as specified in PRD `S`

13. [ ] Print Support — Implement File > Print with print-friendly styles, hide UI chrome, handle page breaks properly `S`

14. [ ] Settings Window — Create native Settings window with font selection (body and heading fonts), font size controls with lock proportions toggle, heading weight/italic/spacing controls `L`

15. [ ] Settings: Spacing and Page Breaks — Add line height, paragraph spacing, list spacing controls; implement page break estimator with auto-adjust and visual indicators `M`

16. [ ] Settings Persistence and Live Update — Persist all settings in UserDefaults, apply changes immediately to open documents via JavaScript bridge, implement Reset to Defaults `S`

> Notes
> - Items ordered by technical dependencies and incremental building of functionality
> - Core rendering and navigation (items 1-8) form the MVP
> - Live reload and file associations (items 9-10) add essential workflow integration
> - Multi-window and menus (items 11-12) complete the macOS app experience
> - Settings (items 14-16) add customization as a final layer
