# Product Mission

## Pitch

Markdown Viewer is a native macOS application for viewing Markdown files with GitHub-style rendering, optimized for distraction-free reading with vi-style keyboard navigation.

## Users

### Primary User

**The Developer** (personal tool)
- **Context:** Daily work involves reading and reviewing Markdown files (documentation, notes, READMEs, specs)
- **Pain Points:**
  - Existing viewers lack keyboard-driven navigation
  - Browser-based solutions feel heavy and disconnected from the filesystem
  - Want to read, not edit (most tools are editors first)
- **Goals:**
  - Open and read Markdown files quickly with native macOS integration
  - Navigate efficiently using familiar vi-style keybindings
  - Have files auto-update when editing them in a separate editor

## The Problem

### Markdown Reading is an Afterthought

Most Markdown tools are editors that happen to have preview modes. For reading-focused workflows (reviewing docs, reading notes, checking rendered output), these tools add friction: slow startup, editing UI in the way, no keyboard navigation.

**Our Solution:** A purpose-built viewer that treats reading as the primary use case. Native macOS performance, vi-style navigation, and live reload for when you're editing in your preferred editor.

## Differentiators

### Reading-First Design
Unlike Markdown editors with preview panes, this is a viewer. No editing UI, no mode switching. Open a file and read it.

### Vi-Style Navigation
Full vi-style keyboard navigation (j/k scrolling, gg/G for top/bottom, /search with n/N) for users who live in the terminal.

### Native macOS Integration
Proper file associations, multiple windows, system theme support, and macOS-native performance. Feels like it belongs on the system.

### Live Reload
Edit in your preferred editor, see changes automatically. The viewer watches the file and re-renders on save.

## Key Features

### Core Features
- **GitHub-Flavored Markdown:** Full GFM support including tables, task lists, code blocks with syntax highlighting
- **File Associations:** Double-click .md files in Finder to open directly
- **Theme Support:** Light and dark themes that respect system appearance

### Navigation Features
- **Vi-Style Scrolling:** j/k, gg/G, Ctrl+d/u, Ctrl+f/b for efficient keyboard navigation
- **Vi-Style Search:** / to search, n/N for next/previous, real-time highlighting
- **Internal Links:** Anchor links scroll smoothly to targets with visual highlighting

### Productivity Features
- **Live Reload:** Automatic re-render when file changes on disk
- **Typography Settings:** Extensive customization via Settings menu:
  - **Fonts:** Body font and heading font selection (with custom font name entry)
  - **Font Sizes:** Body size with optional locked proportions for H1-H6 scaling
  - **Heading Styles:** Per-heading weight, italic toggle, and spacing (before/after in em)
  - **General Spacing:** Line height, paragraph spacing, list spacing
  - **Page Break Estimator:** Auto-adjusting page height calibration with optional page break indicators
- **Page Break Control:**
  - Visual page break indicators in the editor view
  - Manual page breaks via Markdown comment notation (e.g., `<!-- page-break -->`)
  - Ability to force early breaks to keep content together on the next page
- **Print Support:** Clean print output with intelligent page breaks
