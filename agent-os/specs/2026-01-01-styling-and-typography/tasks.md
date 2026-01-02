# Task Breakdown: Styling and Typography

## Overview
Total Tasks: 6

This is a minimal-scope change: updating a single CSS value (body font-size from 14px to 18px) in an embedded style block within `WebView.swift`. The change is isolated and low-risk, but requires visual verification across multiple Markdown elements.

## Task List

### CSS Modification

#### Task Group 1: Typography Update
**Dependencies:** None

- [x] 1.0 Complete typography update
  - [x] 1.1 Read current CSS implementation
    - File: `/Users/gwr/Documents/dev/mdv/Markdown Viewer/WebView.swift`
    - Locate `wrapInHTML` method (lines 146-279)
    - Confirm current `font-size: 14px` on line 149
  - [x] 1.2 Modify body font-size
    - Change `font-size: 14px;` to `font-size: 18px;`
    - Preserve all surrounding CSS rules
    - No other changes to the file
  - [x] 1.3 Build and verify compilation
    - Run `xcodebuild` or build via Xcode
    - Confirm no build errors or warnings introduced

**Acceptance Criteria:**
- Body font-size changed from 14px to 18px
- No other CSS or Swift code modified
- Project builds successfully

### Visual Verification

#### Task Group 2: Manual Testing
**Dependencies:** Task Group 1

- [ ] 2.0 Complete visual verification
  - [ ] 2.1 Prepare test Markdown file
    - Create or locate a file containing: h1-h6 headers, body paragraphs, code blocks (inline and fenced), tables, blockquotes, lists (ordered, unordered, task lists), links, and images
  - [ ] 2.2 Verify body text rendering
    - Open test file in the updated application
    - Confirm body text appears at 18px (larger, more readable)
    - Confirm line-height remains at 1.6 (consistent spacing)
  - [ ] 2.3 Verify header scaling
    - Confirm h1 renders at approximately 36px (2em of 18px)
    - Confirm h2 renders at approximately 27px (1.5em of 18px)
    - Confirm h3 renders at approximately 22.5px (1.25em of 18px)
    - Confirm h4-h6 scale proportionally
  - [ ] 2.4 Verify code blocks unchanged
    - Confirm inline code and fenced code blocks remain at 13px monospace
    - Confirm code block background and padding unchanged
  - [ ] 2.5 Verify other elements unchanged
    - Tables: styling and alignment preserved
    - Blockquotes: left border and padding preserved
    - Lists: bullet/number styling and indentation preserved
    - Links: color and hover states preserved
    - Images: max-width and display preserved
  - [ ] 2.6 Verify responsive behavior
    - Resize window to narrow width (under 980px)
    - Confirm content reflows properly
    - Confirm no horizontal scrolling on text content
  - [ ] 2.7 Verify dark mode
    - Toggle system appearance to dark mode
    - Confirm all dark mode colors still apply correctly
    - Confirm body text renders at 18px in dark mode

**Acceptance Criteria:**
- Body text visually larger and more readable
- Headers scale proportionally with new base size
- Code blocks remain at smaller fixed size (13px)
- All other Markdown elements render correctly
- Responsive reflow works at narrow widths
- Dark mode styling fully functional

## Execution Order

1. CSS Modification (Task Group 1) - Make the single-line change
2. Visual Verification (Task Group 2) - Manually verify all acceptance criteria

## Notes

- This spec involves a single CSS value change with no automated tests
- All verification is visual/manual as specified in the spec's Testing Approach section
- No database, API, or complex UI component work required
- The change is intentionally minimal to avoid scope creep
