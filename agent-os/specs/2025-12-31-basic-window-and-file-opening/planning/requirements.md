# Spec Requirements: Basic Window and File Opening

## Initial Description

Create main window with WKWebView, implement File > Open and drag-and-drop file opening, display filename in window title. This is the foundational first item in the product roadmap (item #1, size M).

From roadmap:
> Basic Window and File Opening - Create main window with WKWebView, implement File > Open and drag-and-drop file opening, display filename in window title

## Requirements Discussion

### First Round Questions

**Q1:** I assume this spec focuses solely on opening and displaying files, with the WKWebView initially showing placeholder content (or empty state) since markdown rendering is a separate roadmap item (#2). Is that correct, or should the WKWebView display raw markdown text as a temporary fallback?
**Answer:** Show raw markdown text as temporary fallback (until rendering is implemented in item #2)

**Q2:** For File > Open (Cmd+O), I'm assuming we should use the standard NSOpenPanel filtered to `.md` and `.markdown` file types. Should we also accept any text file, or strictly limit to markdown extensions?
**Answer:** Restrict to `.md` and `.markdown` only

**Q3:** For drag-and-drop, I'm planning to support dropping files onto the window content area and dropping files onto the app icon in the Dock. Is that correct? Should dropping on the window replace the current file, or open a new window?
**Answer:** Only support dropping onto window content area (not Dock icon). Dropping replaces the current file in that window. File > Open and Cmd+O should open a NEW window, leaving existing windows as-is.

**Q4:** For the window title, I assume we display just the filename (e.g., "README.md") rather than the full path. Is that correct, or would you prefer the path or a "filename - Markdown Viewer" format?
**Answer:** Full path but substitute `~` for user's home directory (e.g., `~/Documents/notes/README.md`)

**Q5:** Since this is the first spec in the roadmap, I assume we're creating the initial Xcode project structure from scratch. Should I assume a standard SwiftUI App lifecycle with a Document-based architecture, or a simpler WindowGroup approach that we refactor later when adding multi-window support?
**Answer:** User doesn't know enough to choose - take the path that leaves the future more flexible (recommend Document-based architecture since it naturally supports multi-window)

**Q6:** For the initial window, I'm assuming default sizing (perhaps 800x600 or similar reasonable default) without persisting window position yet, since window position memory is listed under item #11. Is that correct?
**Answer:** Start with 800x600, no position persistence yet

**Q7:** What should happen if a user tries to open an invalid file or a non-markdown file via drag-and-drop? I assume we show a standard macOS alert, but should we silently ignore it instead?
**Answer:** Show alert "Not a markdown file" (or similar) with OK button, then return to file chooser modal

**Q8:** Is there anything specific you want to explicitly exclude from this spec that I might otherwise assume is included?
**Answer:** None specified - keep it simple

### Existing Code to Reference

No similar existing features identified for reference.

### Follow-up Questions

None required - answers were comprehensive.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Direction:
- Simple, clean rendering with minimal decoration
- Reference point: Mac Preview app without thumbnails, annotations, etc.
- No wireframes or mockups - straightforward implementation

## Requirements Summary

### Functional Requirements

**Window Creation:**
- Create main application window with WKWebView as content area
- Initial window size: 800x600
- No window position persistence in this spec

**File Opening - Menu/Keyboard:**
- File > Open menu item with Cmd+O shortcut
- Opens standard NSOpenPanel file picker
- Filter to `.md` and `.markdown` files only
- Opening a file via menu/keyboard creates a NEW window (does not replace current)

**File Opening - Drag and Drop:**
- Support drag-and-drop onto the window content area only
- Dock icon drop NOT supported in this spec
- Dropping a file REPLACES the current file in that window

**File Display:**
- Display raw markdown text in WKWebView (temporary until item #2 implements rendering)
- Window title shows file path with `~` substituted for home directory
  - Example: `~/Documents/notes/README.md`

**Error Handling:**
- Invalid/non-markdown file: Show alert "Not a markdown file" with OK button
- After dismissing alert, return to file chooser modal (if triggered from File > Open)

**Architecture:**
- Document-based architecture (SwiftUI DocumentGroup) for future flexibility
- Creates foundation for multi-window support (item #11)

### Reusability Opportunities

No existing code to reference - this is a greenfield implementation.

### Scope Boundaries

**In Scope:**
- Main window with WKWebView
- File > Open menu with Cmd+O shortcut
- NSOpenPanel filtered to markdown files
- Drag-and-drop onto window (replaces current file)
- Window title with abbreviated path (~)
- Raw markdown text display (temporary)
- Basic error alert for invalid files
- Initial Xcode project setup with Document-based architecture

**Out of Scope:**
- Markdown rendering (item #2)
- Dock icon drag-and-drop
- Window position/size persistence (item #11)
- Multiple windows management UI (item #11)
- Theme support (item #4)
- Any menu items beyond File > Open
- Print support
- Settings

### Technical Considerations

- Platform: macOS 13.0 (Ventura) or later
- Architecture: Swift/SwiftUI with Document-based app lifecycle
- WKWebView for content display (prepares for markdown-it integration in item #2)
- Universal binary (Apple Silicon and Intel)
- Standard macOS file picker (NSOpenPanel)
- Path display should use `NSString.abbreviatingWithTildeInPath` or equivalent
