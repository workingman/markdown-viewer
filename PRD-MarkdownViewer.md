# Markdown Viewer for macOS - Product Requirements Document

## Overview

A native macOS application for viewing Markdown files with GitHub-style rendering, optimized for distraction-free reading.

## Core Features

### File Opening
- Open markdown files via:
  - Double-click in Finder (file association with `.md` and `.markdown` extensions)
  - File > Open menu (Cmd+O)
  - Drag-and-drop onto app icon or window
  - Clicking dock icon when app is running (opens new empty window or file picker)
- Support multiple open windows (one file per window)
- Window title shows filename

### Markdown Rendering
- GitHub-flavored markdown rendering using markdown-it library (v14)
- markdown-it-anchor plugin (v9) for automatic header ID generation
- GitHub-style slugification for anchor IDs
- Support for:
  - Headers (h1-h6)
  - Bold, italic, strikethrough
  - Code blocks with syntax highlighting
  - Inline code
  - Blockquotes
  - Ordered and unordered lists
  - Task lists (checkboxes)
  - Tables
  - Horizontal rules
  - Links (external and internal anchors)
  - Images

### Internal Navigation
- Internal anchor links (e.g., `[Jump to Section](#section-name)`) scroll to target
- Animated highlighting when jumping to anchor targets (brief yellow flash)
- Smart scrolling: instant scroll for distances > 2.5 viewport heights, smooth scroll for shorter distances

### Theme Support
- Light and dark theme toggle
- Theme preference persists across sessions (stored in UserDefaults)
- Respects system appearance preference as default
- Toggle via View menu or keyboard shortcut (Cmd+Shift+T)

### Live Reload
- Monitor open file for changes
- Automatically re-render when file is modified externally
- Preserve scroll position during reload
- Poll interval: 1 second

### File Refresh
- Manual refresh via View > Refresh (Cmd+R)
- Reload current file from disk
- Preserve scroll position

### Vi-Style Keyboard Navigation

#### Vertical Movement
- `j` - Scroll down (smart scroll)
- `k` - Scroll up (smart scroll)
- `gg` - Go to top of document (smart scroll)
- `G` - Go to bottom of document (smart scroll)
- `Ctrl+d` - Scroll half page down (instant)
- `Ctrl+u` - Scroll half page up (instant)
- `Ctrl+f` - Scroll full page down (instant)
- `Ctrl+b` - Scroll full page up (instant)

#### Horizontal Movement
- `h` - Scroll left (smart scroll)
- `l` - Scroll right (smart scroll)
- `0` - Scroll to far left (smart scroll)
- `$` - Scroll to far right (smart scroll)

### Vi-Style Search
- `/` - Open search box
- Type search query, results highlight in real-time
- `n` - Jump to next match (smart scroll)
- `N` - Jump to previous match (smart scroll)
- `Enter` - Jump to next match and close search box
- `Shift+Enter` - Jump to previous match and close search box
- `Esc` - Close search box and clear highlights
- Match count displayed in search box

### Typography & Styling
- Default font size: 18px
- GitHub Markdown CSS for consistent styling
- Customizable fonts (serif/sans-serif options)
- Adjustable line height
- Maximum content width for readability
- Responsive design

### Print Support
- File > Print (Cmd+P)
- Print-friendly styles (hide UI chrome, optimize for paper)
- Proper page break handling

### Window Management
- Remember window size and position per file
- File > New Window (Cmd+N) opens empty viewer or file picker
- File > Close (Cmd+W) closes current window
- Standard macOS window controls (minimize, zoom, fullscreen)

## Menu Structure

### File Menu
- New Window (Cmd+N)
- Open... (Cmd+O)
- Close (Cmd+W)
- Print... (Cmd+P)

### Edit Menu
- Find... (Cmd+F) - alternative to `/` search
- Copy (Cmd+C) - copy selected text

### View Menu
- Toggle Theme (Cmd+Shift+T)
- Refresh (Cmd+R)
- Actual Size (Cmd+0)
- Zoom In (Cmd+Plus)
- Zoom Out (Cmd+Minus)
- Enter Full Screen (Ctrl+Cmd+F)

### Window Menu
- Minimize (Cmd+M)
- Zoom
- Bring All to Front

### Help Menu
- Keyboard Shortcuts

## Technical Requirements

### Platform
- macOS 13.0 (Ventura) or later
- Universal binary (Apple Silicon and Intel)
- Signed and notarized for distribution

### File Associations
- Register as handler for:
  - `.md` files
  - `.markdown` files
- UTI: `net.daringfireball.markdown`
- Appear in "Open With" menu for markdown files

### Architecture
- Native Swift/SwiftUI application
- WKWebView for markdown rendering
- markdown-it JavaScript library embedded in app bundle
- UserDefaults for preference storage

### Performance
- Open files instantly (< 100ms for typical files)
- Smooth scrolling at 60fps
- Efficient live reload (minimal CPU when idle)

## Settings (Preferences)

Access via Markdown Viewer > Settings... (Cmd+,) - native macOS Settings window.

### Fonts
- Body Font: dropdown with presets (Source Sans 3, Roboto, Open Sans, Lato, Merriweather, Georgia, Arial, Helvetica, Times New Roman) plus custom entry
- Heading Font: dropdown with presets (Barlow, Roboto Slab, Playfair Display, Montserrat, Oswald, Raleway, Georgia, Arial, Helvetica) plus custom entry

### Font Sizes
- Body Size (pt) - default 10.5
- Lock Proportions toggle - when enabled, heading sizes scale proportionally with body size
- H1-H6 Sizes (pt) - defaults: H1=31.5, H2=15, H3=11.5, H4-H6=10.5

### Heading Styles
- H1-H6 Weight (100-900) - defaults: H1=900, H2=700, H3=700, H4=500, H5=400, H6=400
- H1-H6 Italic toggle - default: only H4 is italic
- H1-H6 Spacing Before/After (em) - per-heading margin control

### General Spacing
- Line Height - default 1.4
- Paragraph Spacing (em) - default 0.5
- List Spacing (em) - default 0.3

### Page Break Estimator
- Auto-Adjust Page Height toggle - scales page height based on content density
- Page Height (pixels) - default 1056 (US Letter at 96dpi)
- Show Page Break Indicators toggle
- Reset Calibration button - clears learned adjustments

### Settings Behavior
- All settings persist via UserDefaults
- Settings changes apply immediately to open documents
- "Reset to Defaults" button restores all settings
- Settings communicated to WKWebView via JavaScript bridge

## Out of Scope (v1.0)
- Editing markdown files
- Export to PDF/HTML
- Multiple panes/split view
- Outline/table of contents sidebar
- Custom CSS injection
- Plugin system
