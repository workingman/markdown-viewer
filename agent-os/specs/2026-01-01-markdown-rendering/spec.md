# Specification: Markdown Rendering

## Goal
Integrate markdown-it with plugins to render GitHub-flavored markdown in WKWebView, replacing the current raw text display with properly parsed HTML output.

## User Stories
- As a user, I want to view markdown files with proper formatting (headers, lists, tables, code blocks) so that I can read documentation as intended
- As a user, I want to click external links and have them open in my browser so that I can follow references

## Specific Requirements

**Bundle JavaScript Libraries as App Resources**
- Create a Resources folder in the Xcode project
- Download and bundle markdown-it v14 (markdown-it.min.js)
- Download and bundle markdown-it-anchor v9 (markdown-it-anchor.min.js)
- Download and bundle markdown-it-task-lists (markdown-it-task-lists.min.js)
- Configure Xcode to copy these files to the app bundle

**Configure markdown-it Parser**
- Initialize markdown-it with options: `{ html: false, linkify: true, typographer: false }`
- Enable built-in table support
- Enable built-in strikethrough (GFM) via options
- Register markdown-it-anchor plugin with GitHub-style slugify function
- Register markdown-it-task-lists plugin for checkbox rendering

**Generate Proper HTML Structure for Code Blocks**
- Render code blocks with `<pre><code class="language-X">` structure
- Preserve the language identifier in the class attribute for future syntax highlighting
- Apply basic monospace styling only (no syntax highlighting in this spec)

**Generate GitHub-style Header IDs**
- Use markdown-it-anchor to auto-generate IDs on all header elements
- Implement GitHub-style slugification: lowercase, replace spaces with hyphens, remove special characters
- Ensure duplicate headers get unique suffixes (header, header-1, header-2)

**Update WebView to Use markdown-it**
- Modify `wrapInHTML()` to include script tags loading bundled JS files
- Add inline JavaScript to initialize markdown-it and render the content
- Pass raw markdown to JavaScript for client-side rendering
- Wrap rendered output in `<div class="markdown-body">[content]</div>`

**Pass baseURL for Relative Image Resolution**
- Modify WebView to accept an optional file URL parameter
- Extract parent directory from file URL to use as baseURL
- Update `loadHTMLString()` calls to pass baseURL parameter
- Update ContentView to pass currentFileURL to WebView

**Handle External Links**
- Implement WKNavigationDelegate on WebView
- Intercept navigation actions for http/https URLs
- Open external URLs in system default browser via NSWorkspace.shared.open()
- Allow internal anchor links (same-page navigation) to proceed normally

**Handle Internal Anchor Links**
- Allow WKWebView to handle anchor navigation natively
- Anchor links should scroll to the corresponding header ID

## Visual Design
No visual assets provided. This spec focuses on rendering engine integration; styling will be addressed in a future spec.

## Existing Code to Leverage

**WebView.swift - WKWebView Wrapper**
- NSViewRepresentable pattern for hosting WKWebView in SwiftUI
- `wrapInHTML()` method provides the template for HTML generation
- Coordinator class pattern for maintaining state between updates
- Content change detection via `lastContent` comparison

**ContentView.swift - File URL Tracking**
- Already tracks `currentFileURL` as State property
- Passes document content to WebView
- Pattern for passing additional parameters to WebView can be extended

**PathHelper.swift - URL Utilities**
- Shows existing pattern for URL manipulation
- Can reference for extracting parent directory from file URL

**MarkdownDocument.swift - Document Model**
- Read-only document pattern with content as String
- Shows how file data flows through the app

## Out of Scope
- Syntax highlighting for code blocks (future spec)
- Custom CSS styling beyond basic structure (spec 3: Styling and Typography)
- Dark mode support and theme switching (spec 4: Theme Support)
- Vi-style keyboard navigation (specs 6-8)
- Live reload when file changes (spec 9)
- Math/LaTeX rendering
- Mermaid diagram rendering
- Custom emoji support
- Editing or modifying markdown content
