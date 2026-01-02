# Specification: Basic Window and File Opening

## Goal

Create the foundational macOS application structure with a document-based architecture, enabling users to open and view markdown files via File > Open menu or drag-and-drop, displaying raw markdown text in a WKWebView with the file path shown in the window title.

## User Stories

- As a developer, I want to open markdown files using Cmd+O so that I can quickly view documentation from anywhere on my system
- As a developer, I want to drag markdown files onto an open window so that I can replace the current content without opening additional windows

## Specific Requirements

**Xcode Project Setup**
- Create new macOS app project named "Markdown Viewer" with bundle identifier `com.mdv.markdown-viewer`
- Configure for macOS 13.0 (Ventura) minimum deployment target
- Build as Universal binary (Apple Silicon and Intel)
- Use SwiftUI App lifecycle with DocumentGroup for document-based architecture
- Create a custom document type for markdown files (UTType conformance)

**Document Model**
- Create MarkdownDocument conforming to FileDocument protocol
- Support reading `.md` and `.markdown` file extensions via UTType
- Store file content as String for display in WKWebView
- Implement required `init(configuration:)` and `fileWrapper(configuration:)` methods
- Mark document as read-only (no write capability needed for viewer)

**Main Window with WKWebView**
- Create ContentView that hosts WKWebView via NSViewRepresentable wrapper
- Initial window size: 800x600 pixels (default, no persistence)
- WKWebView fills the entire window content area
- Display raw markdown text wrapped in basic HTML structure (pre tag or similar)
- Use monospace font for raw text display to maintain formatting

**File > Open Menu (Cmd+O)**
- Implement standard File > Open menu item with Cmd+O keyboard shortcut
- DocumentGroup handles this automatically, but ensure it opens new window
- NSOpenPanel filters to `.md` and `.markdown` files only (UTType filter)
- Opening a file creates a NEW window (does not replace existing windows)
- Multiple files can be open simultaneously in separate windows

**Drag-and-Drop on Window**
- Implement drop target on window content area (WKWebView or overlay)
- Accept only `.md` and `.markdown` files
- Dropping REPLACES current file content in that window (not new window)
- Visual feedback during drag (highlight drop zone)
- Dock icon drop is explicitly NOT supported in this spec

**Window Title with Path**
- Display file path in window title bar
- Substitute user's home directory with `~` for brevity
- Example: `~/Documents/notes/README.md` instead of full path
- Use FileManager or NSString.abbreviatingWithTildeInPath for substitution
- Empty/new windows show app name or placeholder text

**Error Handling for Invalid Files**
- Detect non-markdown files dropped on window or selected in open panel
- Display native macOS alert: "Not a markdown file" with OK button
- After dismissing alert from File > Open, return user to file picker modal
- Handle file read errors gracefully with appropriate error messages

**App Lifecycle**
- App launches to empty state or file picker (based on DocumentGroup behavior)
- Cmd+Q quits the application
- Cmd+W closes current window (standard DocumentGroup behavior)
- No special empty state UI needed (WKWebView can show blank content)

## Visual Design

No visual mockups provided. Design direction:
- Simple, clean interface with minimal decoration
- Reference: Mac Preview app aesthetic (content-focused, no sidebars)
- WKWebView as the sole content area (full window)
- Standard macOS window chrome (title bar, traffic lights)

## Existing Code to Leverage

No existing codebase. This is a greenfield implementation. However, these Apple patterns should be followed:

**Apple DocumentGroup Pattern**
- Use SwiftUI's DocumentGroup for automatic document handling
- Provides File menu, recent documents, and multi-window support for free
- Handles open panel presentation and file coordination

**NSViewRepresentable for WKWebView**
- Standard pattern for hosting AppKit views in SwiftUI
- Implement makeNSView and updateNSView methods
- Handle configuration and updates separately

**UTType for File Types**
- Define custom UTType conforming to `public.text` hierarchy
- Use `net.daringfireball.markdown` or define app-specific UTType
- Configure in Info.plist for proper file association groundwork

## Out of Scope

- Markdown rendering and HTML conversion (spec #2)
- Syntax highlighting or styled text display
- Dock icon drag-and-drop support
- Theme support (light/dark modes) (spec #4)
- Window position and size persistence (spec #11)
- Vi-style keyboard navigation (spec #6-8)
- Live reload / file watching (spec #9)
- File associations in Finder (spec #10)
- Print functionality (spec #13)
- Settings or preferences window (spec #14)
- Any menu items beyond File > Open, Close, Quit
- Copy/paste functionality
- Zoom controls
- Search functionality
