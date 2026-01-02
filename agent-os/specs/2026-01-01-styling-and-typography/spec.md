# Spec: Styling and Typography

## Overview

Enhance the Markdown Viewer's typography by increasing the base body font size from 14px to 18px for improved readability, while maintaining GitHub-style appearance, responsive layout, and existing dark mode support.

## Current State

The application renders Markdown content in a WKWebView with embedded CSS styling in `WebView.swift`. The current implementation includes:

- **Body font-size:** 14px (too small for comfortable reading)
- **Line-height:** 1.6 (good, keep as-is)
- **Max-width:** 980px on `.markdown-body` (good, keep as-is)
- **Font family:** System fonts (-apple-system, BlinkMacSystemFont, etc.)
- **Dark mode:** Implemented via `prefers-color-scheme` media query
- **Headers:** Scaled using em units (h1: 2em, h2: 1.5em, h3: 1.25em, etc.)
- **Code blocks:** 13px monospace font with background styling
- **Tables, blockquotes, lists, links:** All styled with GitHub-like appearance

The CSS is embedded inline within the `wrapInHTML` method (lines 146-279).

## Requirements

### Primary Change

Increase the body font-size from 14px to 18px for improved readability.

### Preservation Requirements

The following must remain unchanged:
- Line-height of 1.6
- Max-width of 980px for content container
- System font stack
- All dark mode color values and media query
- Header scaling ratios (em-based, will auto-adjust)
- Code block styling (keep 13px monospace - appropriate for code)
- Table, blockquote, list, link, and image styling
- Responsive text reflow behavior

## Technical Approach

### File to Modify

`Markdown Viewer/WebView.swift`

### Change Location

Line 149 in the `wrapInHTML` method, within the `<style>` block:

```swift
// Current (line 149):
font-size: 14px;

// Change to:
font-size: 18px;
```

### Impact Analysis

| Element | Current Size | After Change | Notes |
|---------|-------------|--------------|-------|
| Body text | 14px | 18px | Primary change |
| H1 | 28px (2em) | 36px (2em) | Auto-scales |
| H2 | 21px (1.5em) | 27px (1.5em) | Auto-scales |
| H3 | 17.5px (1.25em) | 22.5px (1.25em) | Auto-scales |
| H4 | 14px (1em) | 18px (1em) | Auto-scales |
| H5 | 12.25px (0.875em) | 15.75px (0.875em) | Auto-scales |
| H6 | 11.9px (0.85em) | 15.3px (0.85em) | Auto-scales |
| Code | 13px | 13px | Fixed, no change |

## Acceptance Criteria

- [ ] Body text renders at 18px font size
- [ ] Headers scale proportionally (h1 at 36px, h2 at 27px, etc.)
- [ ] Code blocks remain at 13px monospace
- [ ] Line-height remains at 1.6
- [ ] Max content width remains at 980px
- [ ] Dark mode colors and styling unchanged
- [ ] Content reflows properly when window is resized to smaller widths
- [ ] All existing features (tables, blockquotes, lists, links, images, task lists) render correctly

## Out of Scope

- Adding new CSS features or components
- Modifying dark mode implementation
- Adding syntax highlighting for code blocks
- Typography settings UI (future Settings spec)
- Print-specific styles (future Print Support spec)

## Testing Approach

1. Open a Markdown file containing headers (h1-h6), body text, code blocks, tables, blockquotes, and lists
2. Visually verify body text is larger and more readable
3. Verify headers scale proportionally
4. Verify code blocks remain at smaller fixed size
5. Resize window to narrow width to confirm responsive reflow
6. Toggle system appearance to verify dark mode still works
7. Compare visual appearance to GitHub's Markdown rendering for style consistency
