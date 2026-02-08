import SwiftUI
import WebKit
import AppKit

// MARK: - WebViewManager

/// Manages the active WKWebView instance for menu command handling
final class WebViewManager: ObservableObject {
    static let shared = WebViewManager()

    /// The currently active WKWebView
    weak var activeWebView: WKWebView?

    /// Current zoom level (1.0 = 100%)
    @Published private(set) var zoomLevel: CGFloat = 1.0

    private let zoomStep: CGFloat = 0.1
    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 3.0

    private init() {}

    func zoomActualSize() {
        zoomLevel = 1.0
        activeWebView?.pageZoom = zoomLevel
    }

    func zoomIn() {
        zoomLevel = min(zoomLevel + zoomStep, maxZoom)
        activeWebView?.pageZoom = zoomLevel
    }

    func zoomOut() {
        zoomLevel = max(zoomLevel - zoomStep, minZoom)
        activeWebView?.pageZoom = zoomLevel
    }

    func openFind() {
        activeWebView?.evaluateJavaScript("window.viSearch && window.viSearch.open();", completionHandler: nil)
    }

    func print() {
        guard let webView = activeWebView,
              let window = webView.window else { return }

        let printInfo = NSPrintInfo.shared
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36

        let printOperation = webView.printOperation(with: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.view?.frame = webView.bounds

        // Must use runModal instead of run() for WKWebView printing to work
        printOperation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
    }
}

// MARK: - ReadOnlyWebView

/// Custom WKWebView subclass that prevents undo registration
/// This stops the document from being marked as edited when using search
final class ReadOnlyWebView: WKWebView {
    override var undoManager: UndoManager? {
        // Return nil to prevent any undo registration
        return nil
    }
}

// MARK: - WebView

/// NSViewRepresentable wrapper for WKWebView to display markdown content
/// Uses markdown-it with plugins for GitHub-flavored markdown rendering
struct WebView: NSViewRepresentable {
    /// The raw markdown content to display
    let content: String

    /// Optional file URL for resolving relative paths (images, links)
    let fileURL: URL?

    /// Whether to preserve scroll position on content update
    let preserveScroll: Bool

    /// Environment object for appearance preference
    @EnvironmentObject var appearanceManager: AppearanceManager

    /// Initialize WebView with content and optional file URL
    /// - Parameters:
    ///   - content: The raw markdown content to display
    ///   - fileURL: Optional URL of the markdown file for baseURL resolution
    ///   - preserveScroll: Whether to preserve scroll position on reload (default: false)
    init(content: String, fileURL: URL? = nil, preserveScroll: Bool = false) {
        self.content = content
        self.fileURL = fileURL
        self.preserveScroll = preserveScroll
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /// Creates the WKWebView instance
    /// - Parameter context: The representable context
    /// - Returns: Configured WKWebView instance
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = ReadOnlyWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        let html = wrapInHTML(content)
        let baseURL = fileURL?.deletingLastPathComponent()
        webView.loadHTMLString(html, baseURL: baseURL)
        context.coordinator.lastContent = content
        context.coordinator.lastAppearance = appearanceManager.preference

        // Register as active web view for menu commands
        WebViewManager.shared.activeWebView = webView

        return webView
    }

    /// Updates the WKWebView content when the markdown changes
    /// - Parameters:
    ///   - nsView: The WKWebView to update
    ///   - context: The representable context
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Handle content changes
        if content != context.coordinator.lastContent {
            // Save scroll position if preserveScroll is enabled
            if preserveScroll {
                nsView.evaluateJavaScript("JSON.stringify({x: window.scrollX, y: window.scrollY})") { result, _ in
                    if let jsonString = result as? String,
                       let data = jsonString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: CGFloat],
                       let x = json["x"], let y = json["y"] {
                        context.coordinator.pendingScrollPosition = (x, y)
                    }
                }
            }

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
        var pendingScrollPosition: (x: CGFloat, y: CGFloat)?

        /// Called when page finishes loading - restores scroll position if pending
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let position = pendingScrollPosition else { return }
            pendingScrollPosition = nil

            let js = "window.scrollTo(\(position.x), \(position.y));"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

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
        // Escape </script> to prevent premature script tag closure in HTML
        result = result.replacingOccurrences(of: "</script>", with: "<\\/script>", options: .caseInsensitive)
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
                    font-size: 16px;
                    line-height: 1.5;
                    margin: 0;
                    padding: 20px 26px;
                    word-wrap: break-word;
                    display: flex;
                    justify-content: center;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1e1e1e;
                        color: #d4d4d4;
                    }
                    a {
                        color: #4fc1ff;
                    }
                    code {
                        background-color: rgba(110, 118, 129, 0.4);
                        color: #d4d4d4;
                    }
                    pre {
                        background-color: #2d2d2d;
                    }
                    blockquote {
                        border-left-color: #444;
                        color: #9d9d9d;
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
                    width: 100%;
                }
                pre {
                    background-color: #f6f8fa;
                    border-radius: 6px;
                    padding: 16px;
                    overflow: auto;
                }
                code {
                    font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
                    font-size: 14px;
                    background-color: rgba(175, 184, 193, 0.2);
                    color: #9a3412;
                    padding: 0.2em 0.4em;
                    border-radius: 3px;
                }
                pre code {
                    background-color: transparent;
                    color: inherit;
                    padding: 0;
                    font-size: 13px;
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

                /* Anchor target highlight animation */
                @keyframes anchor-highlight {
                    0% { background-color: rgba(255, 208, 0, 0.5); }
                    100% { background-color: transparent; }
                }
                .anchor-highlight {
                    animation: anchor-highlight 1.5s ease-out;
                    border-radius: 3px;
                }
                @media (prefers-color-scheme: dark) {
                    .anchor-highlight {
                        animation-name: anchor-highlight-dark;
                    }
                }
                @keyframes anchor-highlight-dark {
                    0% { background-color: rgba(255, 208, 0, 0.3); }
                    100% { background-color: transparent; }
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
                html.theme-light .anchor-highlight { animation-name: anchor-highlight; }

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
                html.theme-dark .anchor-highlight { animation-name: anchor-highlight-dark; }

                /* Search box */
                .search-box {
                    position: fixed;
                    top: 10px;
                    right: 10px;
                    background: rgba(255, 255, 255, 0.95);
                    border: 1px solid #d0d7de;
                    border-radius: 6px;
                    padding: 8px 12px;
                    display: none;
                    align-items: center;
                    gap: 8px;
                    z-index: 1000;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
                .search-box.visible { display: flex; }
                .search-box input {
                    border: 1px solid #d0d7de;
                    border-radius: 4px;
                    padding: 4px 8px;
                    font-size: 14px;
                    width: 200px;
                    outline: none;
                }
                .search-box input:focus { border-color: #0969da; }
                .search-box .count {
                    font-size: 12px;
                    color: #656d76;
                    min-width: 40px;
                }

                /* Search match highlights */
                .search-match { background-color: rgba(255, 230, 0, 0.5); border-radius: 2px; }
                .search-match-current { background-color: rgba(255, 150, 0, 0.7); }

                /* Search box dark theme */
                @media (prefers-color-scheme: dark) {
                    .search-box {
                        background: rgba(30, 30, 30, 0.95);
                        border-color: #444;
                    }
                    .search-box input {
                        background: #2d2d2d;
                        border-color: #444;
                        color: #d4d4d4;
                    }
                    .search-box input:focus { border-color: #58a6ff; }
                    .search-box .count { color: #999; }
                }

                /* Forced light theme search box */
                html.theme-light .search-box {
                    background: rgba(255, 255, 255, 0.95);
                    border-color: #d0d7de;
                }
                html.theme-light .search-box input {
                    background: #fff;
                    border-color: #d0d7de;
                    color: #1f2328;
                }
                html.theme-light .search-box input:focus { border-color: #0969da; }
                html.theme-light .search-box .count { color: #656d76; }

                /* Forced dark theme search box */
                html.theme-dark .search-box {
                    background: rgba(30, 30, 30, 0.95);
                    border-color: #444;
                }
                html.theme-dark .search-box input {
                    background: #2d2d2d;
                    border-color: #444;
                    color: #d4d4d4;
                }
                html.theme-dark .search-box input:focus { border-color: #58a6ff; }
                html.theme-dark .search-box .count { color: #999; }
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
            <div class="search-box" id="searchBox">
                <input type="text" id="searchInput" placeholder="Search...">
                <span class="count" id="searchCount"></span>
            </div>
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

                // Disable fuzzy link detection (prevents "B.Sc" from becoming a link)
                // Only match URLs with explicit protocols (http://, https://, etc.)
                md.linkify.set({ fuzzyLink: false, fuzzyEmail: false });

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

                // Anchor navigation handler
                document.addEventListener('click', function(e) {
                    var link = e.target.closest('a[href^="#"]');
                    if (!link) return;

                    var targetId = link.getAttribute('href').slice(1);
                    if (!targetId) return;

                    var target = document.getElementById(targetId);
                    if (!target) return;

                    e.preventDefault();

                    // Calculate distance for smart scroll behavior
                    var targetRect = target.getBoundingClientRect();
                    var distance = Math.abs(targetRect.top);
                    var viewportHeight = window.innerHeight;
                    var behavior = distance > viewportHeight * 2 ? 'instant' : 'smooth';

                    // Scroll with offset so heading isn't flush against top
                    var offset = 16;
                    var scrollTop = window.scrollY + targetRect.top - offset;
                    window.scrollTo({ top: Math.max(0, scrollTop), behavior: behavior });

                    // Apply highlight animation
                    target.classList.remove('anchor-highlight');
                    void target.offsetWidth; // Force reflow to restart animation
                    target.classList.add('anchor-highlight');
                });

                // Vi-style vertical navigation
                (function() {
                    var lastKey = '';
                    var lastKeyTime = 0;
                    var LINE_HEIGHT = 40;

                    document.addEventListener('keydown', function(e) {
                        // Ignore if in input field
                        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

                        var key = e.key;
                        var now = Date.now();
                        var viewportHeight = window.innerHeight;

                        // Handle gg sequence
                        if (key === 'g' && !e.ctrlKey && !e.metaKey) {
                            e.preventDefault();
                            if (lastKey === 'g' && (now - lastKeyTime) < 500) {
                                window.scrollTo({ top: 0, behavior: 'instant' });
                                lastKey = '';
                                return;
                            }
                            lastKey = 'g';
                            lastKeyTime = now;
                            return;
                        }

                        // Reset sequence tracking for non-g keys
                        lastKey = '';

                        // Single key bindings
                        switch(key) {
                            case 'j':
                                e.preventDefault();
                                window.scrollBy({ top: LINE_HEIGHT, behavior: 'smooth' });
                                break;
                            case 'k':
                                e.preventDefault();
                                window.scrollBy({ top: -LINE_HEIGHT, behavior: 'smooth' });
                                break;
                            case 'h':
                                e.preventDefault();
                                window.scrollBy({ left: -LINE_HEIGHT, behavior: 'smooth' });
                                break;
                            case 'l':
                                e.preventDefault();
                                window.scrollBy({ left: LINE_HEIGHT, behavior: 'smooth' });
                                break;
                            case '0':
                                e.preventDefault();
                                window.scrollTo({ left: 0, behavior: 'instant' });
                                break;
                            case '$':
                                e.preventDefault();
                                window.scrollTo({ left: document.body.scrollWidth, behavior: 'instant' });
                                break;
                            case 'G':
                                if (!e.ctrlKey && !e.metaKey) {
                                    e.preventDefault();
                                    window.scrollTo({ top: document.body.scrollHeight, behavior: 'instant' });
                                }
                                break;
                            case 'd':
                                if (e.ctrlKey) {
                                    e.preventDefault();
                                    window.scrollBy({ top: viewportHeight / 2, behavior: 'smooth' });
                                }
                                break;
                            case 'u':
                                if (e.ctrlKey) {
                                    e.preventDefault();
                                    window.scrollBy({ top: -viewportHeight / 2, behavior: 'smooth' });
                                }
                                break;
                            case 'f':
                                if (e.ctrlKey) {
                                    e.preventDefault();
                                    window.scrollBy({ top: viewportHeight, behavior: 'smooth' });
                                }
                                break;
                            case 'b':
                                if (e.ctrlKey) {
                                    e.preventDefault();
                                    window.scrollBy({ top: -viewportHeight, behavior: 'smooth' });
                                }
                                break;
                        }
                    });
                })();

                // Vi-style search functionality
                (function() {
                    var searchBox = document.getElementById('searchBox');
                    var searchInput = document.getElementById('searchInput');
                    var searchCount = document.getElementById('searchCount');
                    var matches = [];
                    var currentMatchIndex = -1;

                    function clearHighlights() {
                        document.querySelectorAll('.search-match, .search-match-current').forEach(function(el) {
                            var parent = el.parentNode;
                            parent.replaceChild(document.createTextNode(el.textContent), el);
                            parent.normalize();
                        });
                        matches = [];
                        currentMatchIndex = -1;
                    }

                    function highlightMatches(query) {
                        clearHighlights();
                        if (!query) {
                            searchCount.textContent = '';
                            return;
                        }

                        var content = document.getElementById('content');
                        var walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, null, false);
                        var textNodes = [];
                        while (walker.nextNode()) textNodes.push(walker.currentNode);

                        var escapedQuery = query.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');
                        var regex = new RegExp('(' + escapedQuery + ')', 'gi');

                        textNodes.forEach(function(node) {
                            if (node.nodeValue.match(regex)) {
                                var span = document.createElement('span');
                                span.innerHTML = node.nodeValue.replace(regex, '<mark class="search-match">$1</mark>');
                                node.parentNode.replaceChild(span, node);
                            }
                        });

                        matches = Array.from(document.querySelectorAll('.search-match'));
                        if (matches.length > 0) {
                            currentMatchIndex = 0;
                            updateCurrentMatch();
                        }
                        updateCount();
                    }

                    function updateCurrentMatch() {
                        document.querySelectorAll('.search-match-current').forEach(function(el) {
                            el.classList.remove('search-match-current');
                        });
                        if (matches.length > 0 && currentMatchIndex >= 0) {
                            matches[currentMatchIndex].classList.add('search-match-current');
                            matches[currentMatchIndex].scrollIntoView({ behavior: 'smooth', block: 'center' });
                        }
                    }

                    function updateCount() {
                        if (matches.length > 0) {
                            searchCount.textContent = (currentMatchIndex + 1) + '/' + matches.length;
                        } else if (searchInput.value) {
                            searchCount.textContent = '0/0';
                        } else {
                            searchCount.textContent = '';
                        }
                    }

                    function nextMatch() {
                        if (matches.length === 0) return;
                        currentMatchIndex = (currentMatchIndex + 1) % matches.length;
                        updateCurrentMatch();
                        updateCount();
                    }

                    function prevMatch() {
                        if (matches.length === 0) return;
                        currentMatchIndex = (currentMatchIndex - 1 + matches.length) % matches.length;
                        updateCurrentMatch();
                        updateCount();
                    }

                    function openSearch() {
                        searchBox.classList.add('visible');
                        searchInput.focus();
                        searchInput.select();
                    }

                    function hideSearch() {
                        // Hide box but keep highlights for n/N navigation
                        searchBox.classList.remove('visible');
                        searchInput.blur();
                        document.body.focus();
                    }

                    function closeSearch() {
                        // Fully close - clear highlights and input
                        searchBox.classList.remove('visible');
                        clearHighlights();
                        searchCount.textContent = '';
                        searchInput.value = '';
                        searchInput.blur();
                        document.body.focus();
                    }

                    // Expose functions globally for vi navigation integration
                    window.viSearch = {
                        open: openSearch,
                        hide: hideSearch,
                        close: closeSearch,
                        next: nextMatch,
                        prev: prevMatch,
                        hasMatches: function() { return matches.length > 0; }
                    };

                    // Handle keys in search input
                    searchInput.addEventListener('keydown', function(e) {
                        if (e.key === 'Escape') {
                            closeSearch();
                            e.preventDefault();
                        } else if (e.key === 'Enter') {
                            if (e.shiftKey) {
                                prevMatch();
                            } else {
                                nextMatch();
                            }
                            hideSearch();  // Keep highlights, return focus to doc
                            e.preventDefault();
                        }
                    });

                    // Real-time search as user types
                    searchInput.addEventListener('input', function() {
                        highlightMatches(searchInput.value);
                    });

                    // Global key handler for / and n/N
                    document.addEventListener('keydown', function(e) {
                        // Skip if in input (except for our search handling above)
                        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

                        if (e.key === '/') {
                            e.preventDefault();
                            openSearch();
                        } else if (e.key === 'n' && !e.ctrlKey && !e.metaKey) {
                            if (matches.length > 0) {
                                e.preventDefault();
                                nextMatch();
                            }
                        } else if (e.key === 'N' && !e.ctrlKey && !e.metaKey) {
                            if (matches.length > 0) {
                                e.preventDefault();
                                prevMatch();
                            }
                        }
                    });
                })();
            })();
            </script>
        </body>
        </html>
        """
    }
}
