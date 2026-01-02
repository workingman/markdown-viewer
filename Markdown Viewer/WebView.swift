import SwiftUI
import WebKit
import AppKit

/// NSViewRepresentable wrapper for WKWebView to display markdown content
/// Uses markdown-it with plugins for GitHub-flavored markdown rendering
struct WebView: NSViewRepresentable {
    /// The raw markdown content to display
    let content: String

    /// Optional file URL for resolving relative paths (images, links)
    let fileURL: URL?

    /// Environment object for appearance preference
    @EnvironmentObject var appearanceManager: AppearanceManager

    /// Initialize WebView with content and optional file URL
    /// - Parameters:
    ///   - content: The raw markdown content to display
    ///   - fileURL: Optional URL of the markdown file for baseURL resolution
    init(content: String, fileURL: URL? = nil) {
        self.content = content
        self.fileURL = fileURL
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /// Creates the WKWebView instance
    /// - Parameter context: The representable context
    /// - Returns: Configured WKWebView instance
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        let html = wrapInHTML(content)
        let baseURL = fileURL?.deletingLastPathComponent()
        webView.loadHTMLString(html, baseURL: baseURL)
        context.coordinator.lastContent = content
        context.coordinator.lastAppearance = appearanceManager.preference
        return webView
    }

    /// Updates the WKWebView content when the markdown changes
    /// - Parameters:
    ///   - nsView: The WKWebView to update
    ///   - context: The representable context
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Handle content changes
        if content != context.coordinator.lastContent {
            context.coordinator.lastContent = content
            context.coordinator.lastAppearance = appearanceManager.preference
            let html = wrapInHTML(content)
            let baseURL = fileURL?.deletingLastPathComponent()
            nsView.loadHTMLString(html, baseURL: baseURL)
            return
        }

        // Handle appearance changes (when content hasn't changed)
        if appearanceManager.preference != context.coordinator.lastAppearance {
            context.coordinator.lastAppearance = appearanceManager.preference
            applyAppearance(nsView, preference: appearanceManager.preference)
        }
    }

    /// Applies the current appearance preference to the web view via JavaScript
    /// - Parameters:
    ///   - webView: The WKWebView to apply the theme to
    ///   - preference: The appearance preference to apply
    func applyAppearance(_ webView: WKWebView, preference: AppearancePreference) {
        let js = "applyTheme('\(preference.rawValue)');"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var lastContent: String = ""
        var lastAppearance: AppearancePreference = .system

        /// Intercepts navigation actions to handle external links
        /// - Parameters:
        ///   - webView: The WKWebView requesting navigation
        ///   - navigationAction: Details about the navigation action
        ///   - decisionHandler: Callback to allow or cancel navigation
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Allow initial page load and anchor navigation within the same page
            if navigationAction.navigationType == .other {
                decisionHandler(.allow)
                return
            }

            // Handle anchor links (same-page navigation)
            if url.scheme == nil || url.scheme == "about" {
                decisionHandler(.allow)
                return
            }

            // Handle fragment-only URLs (anchor links)
            if let fragment = url.fragment,
               url.path.isEmpty || url.absoluteString.hasPrefix("#") {
                decisionHandler(.allow)
                return
            }

            // Open external http/https links in system browser
            if url.scheme == "http" || url.scheme == "https" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            // Handle mailto: and other schemes
            if url.scheme == "mailto" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            // Default: allow navigation
            decisionHandler(.allow)
        }
    }

    /// Loads bundled JavaScript file content
    /// - Parameter filename: Name of the JS file (without extension)
    /// - Returns: The JavaScript content as a string, or empty string if not found
    private func loadBundledJS(_ filename: String) -> String {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "js"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }

    /// Escapes a string for safe inclusion in JavaScript string literals
    /// - Parameter string: The string to escape
    /// - Returns: The escaped string safe for JS
    private func escapeForJS(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "\\", with: "\\\\")
        result = result.replacingOccurrences(of: "`", with: "\\`")
        result = result.replacingOccurrences(of: "$", with: "\\$")
        return result
    }

    /// Wraps raw markdown text in HTML with markdown-it rendering
    /// - Parameter markdown: The raw markdown text to render
    /// - Returns: HTML string with rendered markdown content
    func wrapInHTML(_ markdown: String) -> String {
        let markdownItJS = loadBundledJS("markdown-it.min")
        let anchorJS = loadBundledJS("markdown-it-anchor.min")
        let taskListsJS = loadBundledJS("markdown-it-task-lists.min")

        let escapedMarkdown = escapeForJS(markdown)

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="color-scheme" content="light dark" id="colorSchemeTag">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                    font-size: 18px;
                    line-height: 1.6;
                    margin: 16px;
                    word-wrap: break-word;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1e1e1e;
                        color: #d4d4d4;
                    }
                    a {
                        color: #58a6ff;
                    }
                    code {
                        background-color: #2d2d2d;
                    }
                    pre {
                        background-color: #2d2d2d;
                    }
                    blockquote {
                        border-left-color: #444;
                        color: #999;
                    }
                    table th, table td {
                        border-color: #444;
                    }
                    hr {
                        background-color: #444;
                    }
                }
                .markdown-body {
                    max-width: 980px;
                }
                pre {
                    background-color: #f6f8fa;
                    border-radius: 6px;
                    padding: 16px;
                    overflow: auto;
                }
                code {
                    font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
                    font-size: 13px;
                    background-color: #f6f8fa;
                    padding: 0.2em 0.4em;
                    border-radius: 3px;
                }
                pre code {
                    background-color: transparent;
                    padding: 0;
                }
                blockquote {
                    margin: 0;
                    padding: 0 1em;
                    color: #656d76;
                    border-left: 0.25em solid #d0d7de;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin-bottom: 16px;
                }
                table th, table td {
                    padding: 6px 13px;
                    border: 1px solid #d0d7de;
                }
                table th {
                    font-weight: 600;
                    background-color: #f6f8fa;
                }
                table tr:nth-child(2n) {
                    background-color: #f6f8fa;
                }
                @media (prefers-color-scheme: dark) {
                    table tr:nth-child(2n) {
                        background-color: #2d2d2d;
                    }
                    table th {
                        background-color: #2d2d2d;
                    }
                }
                hr {
                    height: 0.25em;
                    padding: 0;
                    margin: 24px 0;
                    background-color: #d0d7de;
                    border: 0;
                }
                img {
                    max-width: 100%;
                    box-sizing: content-box;
                }
                .task-list-item {
                    list-style-type: none;
                }
                .task-list-item input[type="checkbox"] {
                    margin: 0 0.2em 0.25em -1.4em;
                    vertical-align: middle;
                }
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                    line-height: 1.25;
                }
                h1 { font-size: 2em; border-bottom: 1px solid #d0d7de; padding-bottom: 0.3em; }
                h2 { font-size: 1.5em; border-bottom: 1px solid #d0d7de; padding-bottom: 0.3em; }
                h3 { font-size: 1.25em; }
                h4 { font-size: 1em; }
                h5 { font-size: 0.875em; }
                h6 { font-size: 0.85em; color: #656d76; }
                @media (prefers-color-scheme: dark) {
                    h1, h2 { border-bottom-color: #444; }
                    h6 { color: #999; }
                }
                ul, ol {
                    padding-left: 2em;
                }
                li + li {
                    margin-top: 0.25em;
                }
                del {
                    text-decoration: line-through;
                }
                a {
                    color: #0969da;
                    text-decoration: none;
                }
                a:hover {
                    text-decoration: underline;
                }

                /* Forced light theme - overrides media queries */
                html.theme-light body {
                    background-color: #ffffff;
                    color: #1f2328;
                }
                html.theme-light a { color: #0969da; }
                html.theme-light code { background-color: #f6f8fa; }
                html.theme-light pre { background-color: #f6f8fa; }
                html.theme-light blockquote { border-left-color: #d0d7de; color: #656d76; }
                html.theme-light table th, html.theme-light table td { border-color: #d0d7de; }
                html.theme-light table tr:nth-child(2n) { background-color: #f6f8fa; }
                html.theme-light table th { background-color: #f6f8fa; }
                html.theme-light hr { background-color: #d0d7de; }
                html.theme-light h1, html.theme-light h2 { border-bottom-color: #d0d7de; }
                html.theme-light h6 { color: #656d76; }

                /* Forced dark theme - overrides media queries */
                html.theme-dark body {
                    background-color: #1e1e1e;
                    color: #d4d4d4;
                }
                html.theme-dark a { color: #58a6ff; }
                html.theme-dark code { background-color: #2d2d2d; }
                html.theme-dark pre { background-color: #2d2d2d; }
                html.theme-dark blockquote { border-left-color: #444; color: #999; }
                html.theme-dark table th, html.theme-dark table td { border-color: #444; }
                html.theme-dark table tr:nth-child(2n) { background-color: #2d2d2d; }
                html.theme-dark table th { background-color: #2d2d2d; }
                html.theme-dark hr { background-color: #444; }
                html.theme-dark h1, html.theme-dark h2 { border-bottom-color: #444; }
                html.theme-dark h6 { color: #999; }
            </style>
            <script>
            \(markdownItJS)
            </script>
            <script>
            \(anchorJS)
            </script>
            <script>
            \(taskListsJS)
            </script>
            <script>
            // Theme application function - called from Swift
            function applyTheme(preference) {
                var meta = document.getElementById('colorSchemeTag');
                var root = document.documentElement;

                // Remove existing theme classes
                root.classList.remove('theme-light', 'theme-dark', 'theme-system');

                switch(preference) {
                    case 'light':
                        meta.content = 'light';
                        root.classList.add('theme-light');
                        break;
                    case 'dark':
                        meta.content = 'dark';
                        root.classList.add('theme-dark');
                        break;
                    default: // system
                        meta.content = 'light dark';
                        root.classList.add('theme-system');
                        break;
                }
            }
            </script>
        </head>
        <body>
            <div class="markdown-body" id="content"></div>
            <script>
            (function() {
                // GitHub-style slugify function
                function slugify(str) {
                    return str
                        .toLowerCase()
                        .trim()
                        .replace(/[\\s]+/g, '-')
                        .replace(/[^\\w\\-]+/g, '')
                        .replace(/\\-\\-+/g, '-');
                }

                // Initialize markdown-it with options
                var md = window.markdownit({
                    html: false,
                    linkify: true,
                    typographer: false
                });

                // Enable strikethrough (GFM)
                md.options.breaks = false;

                // Register markdown-it-anchor plugin with GitHub-style slugify
                if (window.markdownItAnchor) {
                    md.use(window.markdownItAnchor, {
                        slugify: slugify,
                        permalink: false,
                        uniqueSlugStartIndex: 1
                    });
                }

                // Register markdown-it-task-lists plugin
                if (window.markdownitTaskLists) {
                    md.use(window.markdownitTaskLists, {
                        enabled: false,
                        label: false,
                        labelAfter: false
                    });
                }

                // Render the markdown content
                var markdownContent = `\(escapedMarkdown)`;
                var rendered = md.render(markdownContent);
                document.getElementById('content').innerHTML = rendered;
            })();
            </script>
        </body>
        </html>
        """
    }
}
