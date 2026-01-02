# Spec Requirements: Markdown Rendering

## Initial Description

Integrate markdown-it with markdown-it-anchor plugin, render GitHub-flavored markdown with full syntax support (headers, lists, code blocks, tables, task lists, blockquotes, links, images). This is for a macOS Markdown Viewer app built with SwiftUI and WKWebView.

## Requirements Discussion

### First Round Questions

**Q1:** I assume we should bundle the markdown-it.js and markdown-it-anchor.js files directly in the app bundle (as Resources), rather than fetching them from a CDN at runtime. Is that correct, or do you prefer a different approach?
**Answer:** Yes, bundle markdown-it.js and plugins directly in the app bundle as Resources. No CDN fetching.

**Q2:** For GitHub-Flavored Markdown features (tables, strikethrough, task lists), I'm thinking we use the standalone GFM plugins that come with markdown-it rather than a separate markdown-it-gfm package. Is that the right approach?
**Answer:** Use markdown-it's built-in features plus minimal plugins:
- Enable tables (built-in, needs `html: true` or table option)
- Enable strikethrough (built-in GFM option)
- Add markdown-it-task-lists for task list checkboxes

**Q3:** The roadmap mentions "code blocks with syntax highlighting" as a core feature, but this spec focuses on markdown-it integration. Should this spec include syntax highlighting, just render code blocks unstyled, or render with basic monospace styling only?
**Answer:** Option (c) - Render code blocks with basic monospace styling only. Syntax highlighting will be a separate future spec. Just ensure code blocks have proper `<pre><code>` structure with language class for future highlighting.

**Q4:** For images in markdown, should this spec include image handling with relative paths, absolute paths, and URLs?
**Answer:** Include basic image handling:
- Support absolute file:// URLs
- Support http/https URLs
- Relative paths: resolve against the markdown file's directory (pass base URL to WKWebView)

**Q5:** For external links (http/https), should clicking them open in the system default browser, do nothing, or something else?
**Answer:** Option (a) - External links (http/https) should open in the system default browser. Internal anchor links should scroll within the document.

**Q6:** The markdown-it-anchor plugin generates IDs for headers. Should we use GitHub-style slugification?
**Answer:** Yes, use GitHub-style slugification for header IDs.

**Q7:** For the rendered output HTML structure, is a simple `<div class="markdown-body">[content]</div>` sufficient?
**Answer:** The simple structure is fine:
```html
<div class="markdown-body">
  [rendered content]
</div>
```

**Q8:** Is there anything you explicitly do NOT want included in this spec?
**Answer:**
- No syntax highlighting (future spec)
- No custom CSS styling (that's spec 3)
- No dark mode support (that's spec 4)

### Existing Code to Reference

**Similar Features Identified:**
- Feature: WebView wrapper - Path: `/Users/gwr/Documents/dev/mdv/Markdown Viewer/WebView.swift`
  - Contains current WKWebView wrapper with `wrapInHTML()` method
  - HTML loaded via `loadHTMLString(html, baseURL: nil)` - will need to pass baseURL for image resolution

### Follow-up Questions

No follow-up questions needed - answers were comprehensive.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
N/A - User confirmed this is straightforward markdown rendering with no design mockups needed.

## Requirements Summary

### Functional Requirements
- Bundle markdown-it.js v14 and plugins as app Resources
- Bundle markdown-it-anchor v9 for header ID generation
- Bundle markdown-it-task-lists for task list checkbox support
- Enable markdown-it's built-in table support
- Enable markdown-it's built-in strikethrough (GFM) option
- Render code blocks with `<pre><code class="language-X">` structure for future syntax highlighting
- Generate GitHub-style slugified IDs for all headers
- Resolve relative image paths against the markdown file's directory
- Support absolute file:// URLs for images
- Support http/https URLs for images
- Open external links (http/https) in system default browser
- Scroll to anchor for internal links
- Wrap rendered content in `<div class="markdown-body">`

### Reusability Opportunities
- Existing WebView.swift has the WKWebView wrapper pattern to extend
- Current `wrapInHTML()` method structure can be adapted for markdown-it integration
- `loadHTMLString()` call pattern exists but needs baseURL parameter added

### Scope Boundaries

**In Scope:**
- JavaScript library bundling (markdown-it, markdown-it-anchor, markdown-it-task-lists)
- Markdown parsing and HTML generation
- GFM features: tables, strikethrough, task lists
- Header anchor ID generation (GitHub-style slugification)
- Basic code block structure (no highlighting)
- Image URL resolution (relative, absolute, http/https)
- External link handling (open in browser)
- Internal anchor link scrolling
- Passing baseURL to WKWebView for relative path resolution

**Out of Scope:**
- Syntax highlighting for code blocks (future spec)
- Custom CSS styling (spec 3: Styling and Typography)
- Dark mode support (spec 4: Theme Support)
- Vi-style navigation (spec 6-8)
- Live reload (spec 9)

### Technical Considerations
- JavaScript files must be bundled in app Resources folder
- WKWebView needs baseURL set to markdown file's parent directory
- Need WKNavigationDelegate to intercept external link clicks
- markdown-it configured with: `{ html: false, linkify: true, typographer: false }`
- GFM strikethrough enabled via markdown-it options
- markdown-it-anchor configured with GitHub-style slugify function
