# Task Breakdown: Markdown Rendering

## Overview
Total Tasks: 4 Task Groups, 19 Sub-tasks

This spec integrates markdown-it with plugins to render GitHub-flavored markdown in WKWebView, replacing the current raw text display with properly parsed HTML output.

## Task List

### Resource Setup

#### Task Group 1: Bundle JavaScript Libraries
**Dependencies:** None

- [x] 1.0 Complete JavaScript library bundling
  - [x] 1.1 Write 3-4 focused tests for resource loading
    - Test that markdown-it.min.js loads successfully in WKWebView
    - Test that plugins (anchor, task-lists) load without errors
    - Test that markdown-it initializes with correct configuration
  - [x] 1.2 Create Resources folder structure in Xcode project
    - Create `Resources/js/` folder in `Markdown Viewer/` directory
    - Configure Xcode to include folder in app bundle (Copy Bundle Resources)
  - [x] 1.3 Download and add markdown-it v14
    - Source: https://cdn.jsdelivr.net/npm/markdown-it@14/dist/markdown-it.min.js
    - Save as: `Resources/js/markdown-it.min.js`
  - [x] 1.4 Download and add markdown-it-anchor v9
    - Source: https://cdn.jsdelivr.net/npm/markdown-it-anchor@9/dist/markdownItAnchor.umd.js
    - Save as: `Resources/js/markdown-it-anchor.min.js`
  - [x] 1.5 Download and add markdown-it-task-lists
    - Source: https://cdn.jsdelivr.net/npm/markdown-it-task-lists/dist/markdown-it-task-lists.min.js
    - Save as: `Resources/js/markdown-it-task-lists.min.js`
  - [x] 1.6 Verify resources are copied to app bundle
    - Build project and verify JS files appear in built app bundle
    - Confirm files are accessible at runtime via Bundle.main.url()

**Acceptance Criteria:**
- Resources folder exists in Xcode project
- All three JS files are bundled with the app
- Files are accessible at runtime via Bundle.main

### WebView Integration

#### Task Group 2: Integrate markdown-it Rendering
**Dependencies:** Task Group 1

- [x] 2.0 Complete markdown-it integration in WebView
  - [x] 2.1 Write 4-6 focused tests for markdown rendering
    - Test basic markdown elements render correctly (headers, paragraphs, lists)
    - Test GFM features work (tables, strikethrough, task lists)
    - Test code blocks have correct `<pre><code class="language-X">` structure
    - Test header IDs follow GitHub-style slugification
    - Test duplicate headers get unique suffixes (header, header-1, header-2)
  - [x] 2.2 Update wrapInHTML() to load bundled JS files
    - Add script tags loading markdown-it.min.js, markdown-it-anchor.min.js, markdown-it-task-lists.min.js
    - Use Bundle.main.url() to get correct file paths
    - Reference files via file:// URLs or inline the JS content
  - [x] 2.3 Configure markdown-it parser in JavaScript
    - Initialize with options: `{ html: false, linkify: true, typographer: false }`
    - Enable built-in table support
    - Enable strikethrough via options
    - Register markdown-it-anchor with GitHub-style slugify function
    - Register markdown-it-task-lists plugin
  - [x] 2.4 Implement client-side rendering flow
    - Pass raw markdown content to JavaScript (escape properly for JS string)
    - Call md.render() to generate HTML
    - Wrap output in `<div class="markdown-body">[content]</div>`
  - [x] 2.5 Add baseURL support to WebView
    - Add optional `fileURL: URL?` parameter to WebView
    - Extract parent directory from fileURL for baseURL
    - Update loadHTMLString() calls to pass baseURL parameter
  - [x] 2.6 Update ContentView to pass fileURL
    - Pass currentFileURL from ContentView to WebView
    - Ensure URL is available when document is loaded
  - [x] 2.7 Ensure markdown rendering tests pass
    - Run tests from 2.1
    - Verify all GFM features render correctly

**Acceptance Criteria:**
- The 4-6 tests written in 2.1 pass
- Markdown renders with proper formatting (headers, lists, tables, code blocks)
- Code blocks have `<pre><code class="language-X">` structure
- Header IDs follow GitHub-style slugification
- Relative images resolve correctly via baseURL

### Link Handling

#### Task Group 3: Implement Link Navigation
**Dependencies:** Task Group 2

- [x] 3.0 Complete link handling implementation
  - [x] 3.1 Write 3-4 focused tests for link behavior
    - Test external http/https links trigger system browser open
    - Test internal anchor links scroll within document
    - Test mailto: and other scheme links are handled appropriately
  - [x] 3.2 Implement WKNavigationDelegate on WebView Coordinator
    - Add WKNavigationDelegate conformance to Coordinator class
    - Set coordinator as navigation delegate on WKWebView
  - [x] 3.3 Intercept external link navigation
    - Implement webView(_:decidePolicyFor:decisionHandler:)
    - Check if URL scheme is http or https
    - For external URLs: call NSWorkspace.shared.open() and cancel WebView navigation
    - For anchor links (same-page): allow navigation to proceed
  - [x] 3.4 Verify link handling works correctly
    - Run tests from 3.1
    - Manual verification: external links open in browser
    - Manual verification: anchor links scroll to headers

**Acceptance Criteria:**
- The 3-4 tests written in 3.1 pass
- External http/https links open in system default browser
- Internal anchor links scroll to corresponding headers
- WebView does not navigate away from rendered content

### Testing and Verification

#### Task Group 4: Test Review and Gap Analysis
**Dependencies:** Task Groups 1-3

- [x] 4.0 Review existing tests and fill critical gaps
  - [x] 4.1 Review tests from Task Groups 1-3
    - Review 3-4 tests from resource loading (Task 1.1)
    - Review 4-6 tests from markdown rendering (Task 2.1)
    - Review 3-4 tests from link handling (Task 3.1)
    - Total existing tests: approximately 10-14 tests
  - [x] 4.2 Analyze test coverage gaps for this feature
    - Identify any critical markdown rendering scenarios not covered
    - Focus on edge cases that could cause rendering failures
    - Check for integration gaps between components
  - [x] 4.3 Write up to 6 additional tests if needed
    - Test malformed markdown handling (graceful degradation)
    - Test empty content handling
    - Test very large documents (performance sanity check)
    - Test special characters in headers (slugification edge cases)
    - Test nested markdown structures (lists in blockquotes, etc.)
    - Test image URL resolution (relative, absolute, http)
  - [x] 4.4 Run all feature-specific tests
    - Run all tests related to markdown rendering feature
    - Expected total: approximately 16-20 tests maximum
    - Verify all critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 16-20 tests total)
- Critical rendering scenarios are covered
- Edge cases handled gracefully
- No more than 6 additional tests added when filling gaps

## Execution Order

Recommended implementation sequence:

1. **Task Group 1: Bundle JavaScript Libraries**
   - Must be completed first as WebView integration depends on bundled JS files
   - No code dependencies, purely resource setup

2. **Task Group 2: Integrate markdown-it Rendering**
   - Depends on Task Group 1 (needs bundled JS files)
   - Core feature implementation
   - Can be tested independently with sample markdown

3. **Task Group 3: Implement Link Navigation**
   - Depends on Task Group 2 (needs working markdown rendering to have links to click)
   - Builds on Coordinator pattern already in WebView

4. **Task Group 4: Test Review and Gap Analysis**
   - Depends on all previous groups
   - Final verification and edge case coverage

## Files to Modify

- `Markdown Viewer/WebView.swift` - Main changes for markdown-it integration and link handling
- `Markdown Viewer/ContentView.swift` - Pass fileURL to WebView
- `Markdown Viewer.xcodeproj/project.pbxproj` - Add Resources folder and JS files to build

## Files to Create

- `Markdown Viewer/Resources/js/markdown-it.min.js`
- `Markdown Viewer/Resources/js/markdown-it-anchor.min.js`
- `Markdown Viewer/Resources/js/markdown-it-task-lists.min.js`
