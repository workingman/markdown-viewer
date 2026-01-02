# Task Breakdown: Basic Window and File Opening

## Overview
Total Tasks: 6 Task Groups, 28 Sub-tasks

This is a greenfield macOS application using SwiftUI with Document-based architecture. The tasks are organized to build foundational layers first (project setup, document model) before implementing UI and interaction features.

## Task List

### Project Foundation

#### Task Group 1: Xcode Project Setup
**Dependencies:** None

- [x] 1.0 Complete Xcode project setup
  - [x] 1.1 Create new macOS app project
    - Project name: "Markdown Viewer"
    - Bundle identifier: `com.mdv.markdown-viewer`
    - Interface: SwiftUI
    - Life Cycle: SwiftUI App
    - Language: Swift
  - [x] 1.2 Configure deployment target and architecture
    - Minimum deployment: macOS 13.0 (Ventura)
    - Architectures: Universal (Apple Silicon + Intel)
    - Build Settings: Ensure ARCHS includes arm64 and x86_64
  - [x] 1.3 Configure Info.plist for document types
    - Add UTType declaration for markdown files
    - Configure document type with extensions: `.md`, `.markdown`
    - Use `net.daringfireball.markdown` UTType or define app-specific
    - Conform to `public.text` hierarchy
  - [x] 1.4 Verify project builds and runs
    - Clean build succeeds
    - App launches on target macOS version
    - No warnings or errors in build output

**Acceptance Criteria:**
- Project builds successfully for both architectures
- App launches with empty window
- Info.plist contains proper document type configuration

---

### Document Layer

#### Task Group 2: Document Model
**Dependencies:** Task Group 1

- [x] 2.0 Complete document model implementation
  - [x] 2.1 Write 3-5 focused tests for MarkdownDocument
    - Test successful initialization from valid markdown data
    - Test file reading for both `.md` and `.markdown` extensions
    - Test handling of empty file content
    - Test that document is marked as read-only (no write capability)
  - [x] 2.2 Create MarkdownDocument conforming to FileDocument
    - Implement `init(configuration:)` for reading files
    - Implement `fileWrapper(configuration:)` (read-only, can throw or return empty)
    - Store content as String property
    - Define `readableContentTypes` for markdown UTType
  - [x] 2.3 Define UTType extension for markdown
    - Create UTType.markdown static property
    - Support both `.md` and `.markdown` extensions
    - Ensure proper conformance to `public.text`
  - [x] 2.4 Configure App entry point with DocumentGroup
    - Replace default WindowGroup with DocumentGroup
    - Pass MarkdownDocument as document type
    - Connect to ContentView for document display
  - [x] 2.5 Ensure document model tests pass
    - Run ONLY the 3-5 tests written in 2.1
    - Verify document initializes correctly from file data

**Acceptance Criteria:**
- The 3-5 tests written in 2.1 pass
- MarkdownDocument correctly reads markdown file content
- File > Open menu appears automatically via DocumentGroup
- Opening a markdown file creates a new window with document

---

### UI Layer

#### Task Group 3: WKWebView Integration
**Dependencies:** Task Group 2

- [x] 3.0 Complete WKWebView integration
  - [x] 3.1 Write 3-5 focused tests for WebView wrapper
    - Test that WebView creates successfully
    - Test that content updates when document changes
    - Test that HTML structure wraps markdown in monospace font
  - [x] 3.2 Create WebView NSViewRepresentable wrapper
    - Implement `makeNSView(context:)` to create WKWebView
    - Implement `updateNSView(_:context:)` to update content
    - Configure WKWebView with appropriate settings
  - [x] 3.3 Implement raw markdown display
    - Wrap markdown text in basic HTML structure
    - Use `<pre>` tag or similar for raw text display
    - Apply monospace font (system monospace or similar)
    - Preserve whitespace and formatting
  - [x] 3.4 Create ContentView with WebView
    - Host WebView wrapper as main content
    - Bind to MarkdownDocument content
    - WebView fills entire window content area
  - [x] 3.5 Configure initial window size
    - Set default window size to 800x600 pixels
    - Use `.defaultSize()` modifier or WindowGroup configuration
    - No position persistence (defer to spec #11)
  - [x] 3.6 Ensure WKWebView tests pass
    - Run ONLY the 3-5 tests written in 3.1
    - Verify raw markdown displays correctly in WKWebView

**Acceptance Criteria:**
- The 3-5 tests written in 3.1 pass
- WKWebView displays raw markdown text with monospace font
- Window opens at 800x600 default size
- Content fills entire window area

---

### Window Chrome

#### Task Group 4: Window Title with Path
**Dependencies:** Task Group 3

- [x] 4.0 Complete window title implementation
  - [x] 4.1 Write 2-4 focused tests for path abbreviation
    - Test home directory substitution with `~`
    - Test path outside home directory (no substitution)
    - Test empty/nil path handling
  - [x] 4.2 Implement path abbreviation helper
    - Use `NSString.abbreviatingWithTildeInPath` or FileManager equivalent
    - Handle edge cases (nil path, non-home paths)
    - Return abbreviated path string
  - [x] 4.3 Configure window title to show file path
    - Use `.navigationTitle()` or window title configuration
    - Display abbreviated path (e.g., `~/Documents/notes/README.md`)
    - Show app name or placeholder for empty/new windows
  - [x] 4.4 Ensure window title tests pass
    - Run ONLY the 2-4 tests written in 4.1
    - Verify path displays correctly with ~ substitution

**Acceptance Criteria:**
- The 2-4 tests written in 4.1 pass
- Window title shows abbreviated file path
- Home directory appears as `~`
- Empty windows show appropriate placeholder

---

### File Handling

#### Task Group 5: Drag-and-Drop Support
**Dependencies:** Task Group 4

- [x] 5.0 Complete drag-and-drop implementation
  - [x] 5.1 Write 3-5 focused tests for drag-and-drop
    - Test accepting valid markdown file drop
    - Test rejecting non-markdown file drop
    - Test that drop replaces current content (not new window)
  - [x] 5.2 Implement drop target on content area
    - Add `.onDrop()` modifier to ContentView or WebView
    - Accept file URLs from drag operation
    - Handle drop on WKWebView or overlay view
  - [x] 5.3 Validate dropped files
    - Check file extension is `.md` or `.markdown`
    - Check UTType conformance if available
    - Reject invalid files with appropriate handling
  - [x] 5.4 Replace current document content on valid drop
    - Read dropped file content
    - Update current document (replace, not new window)
    - Update window title with new file path
  - [x] 5.5 Add visual feedback during drag
    - Highlight drop zone when valid file is dragged over
    - Use standard macOS drop highlight or custom overlay
    - Clear highlight when drag exits or completes
  - [x] 5.6 Ensure drag-and-drop tests pass
    - Run ONLY the 3-5 tests written in 5.1
    - Verify drag-and-drop replaces content correctly

**Acceptance Criteria:**
- The 3-5 tests written in 5.1 pass
- Valid markdown files can be dropped on window
- Drop replaces current file content (not new window)
- Visual feedback shown during drag operation
- Non-markdown files are rejected

---

### Error Handling

#### Task Group 6: Error Handling and Validation
**Dependencies:** Task Group 5

- [x] 6.0 Complete error handling implementation
  - [x] 6.1 Write 2-4 focused tests for error handling
    - Test alert appears for non-markdown file
    - Test file read error handling
    - Test return to file picker after error from File > Open
  - [x] 6.2 Implement error alert for invalid files
    - Create native macOS alert using NSAlert or SwiftUI alert
    - Title: "Not a markdown file" (or similar)
    - Single OK button to dismiss
  - [x] 6.3 Handle file read errors
    - Catch errors from file reading operations
    - Display appropriate error message
    - Prevent app crash on malformed files
  - [x] 6.4 Implement return to file picker after error
    - After dismissing alert from File > Open context
    - Re-present file picker modal
    - User can select different file or cancel
  - [x] 6.5 Ensure error handling tests pass
    - Run ONLY the 2-4 tests written in 6.1
    - Verify alerts display correctly
    - Verify file picker returns after error

**Acceptance Criteria:**
- The 2-4 tests written in 6.1 pass
- Invalid file alert displays with OK button
- File read errors show appropriate message
- File picker re-appears after error from File > Open

---

### Integration Testing

#### Task Group 7: Test Review and Gap Analysis
**Dependencies:** Task Groups 1-6

- [x] 7.0 Review existing tests and fill critical gaps
  - [x] 7.1 Review tests from Task Groups 2-6
    - Review tests from document model (2.1)
    - Review tests from WKWebView integration (3.1)
    - Review tests from window title (4.1)
    - Review tests from drag-and-drop (5.1)
    - Review tests from error handling (6.1)
    - Total existing tests: approximately 13-23 tests
  - [x] 7.2 Analyze test coverage gaps for this feature
    - Identify critical user workflows lacking coverage
    - Focus on end-to-end scenarios (open file, view, drag new file)
    - Prioritize integration between components
  - [x] 7.3 Write up to 8 additional strategic tests if needed
    - End-to-end: Open markdown file via Cmd+O, verify content displays
    - End-to-end: Drag-drop file, verify content replaces
    - Integration: Multiple windows open simultaneously
    - Integration: Window title updates after drag-drop
  - [x] 7.4 Run feature-specific tests only
    - Run all tests related to this spec
    - Expected total: approximately 21-31 tests
    - Verify all critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass
- Critical user workflows covered
- App opens files via File > Open (Cmd+O)
- App accepts drag-and-drop replacement
- Window titles display correctly
- Error handling works as specified

---

## Execution Order

Recommended implementation sequence:

1. **Project Foundation (Task Group 1)** - Must be first to create Xcode project
2. **Document Layer (Task Group 2)** - Establishes document model before UI
3. **UI Layer (Task Group 3)** - WKWebView requires document to display
4. **Window Chrome (Task Group 4)** - Title bar depends on document path
5. **File Handling (Task Group 5)** - Drag-drop extends document handling
6. **Error Handling (Task Group 6)** - Validation layer on top of file operations
7. **Integration Testing (Task Group 7)** - Final verification after all features complete

## Notes

**Architecture Decisions:**
- Using DocumentGroup provides File menu, recent documents, and multi-window support automatically
- WKWebView prepares for future markdown-it integration (spec #2)
- Document-based architecture enables per-window state management

**Key Files to Create:**
- `MarkdownViewerApp.swift` - App entry point with DocumentGroup
- `MarkdownDocument.swift` - FileDocument conforming document model
- `ContentView.swift` - Main view hosting WebView
- `WebView.swift` - NSViewRepresentable wrapper for WKWebView
- `UTType+Markdown.swift` - UTType extension for markdown

**Out of Scope Reminders:**
- No markdown rendering (raw text only until spec #2)
- No Dock icon drag-and-drop
- No window position persistence
- No theme/dark mode support
- No menu items beyond File > Open, Close, Quit
