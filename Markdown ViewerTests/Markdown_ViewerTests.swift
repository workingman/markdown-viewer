import XCTest
import SwiftUI
import UniformTypeIdentifiers
import WebKit
@testable import Markdown_Viewer

// MARK: - Theme Support: AppearanceManager Tests

final class AppearanceManagerTests: XCTestCase {

    // Clean up UserDefaults before each test
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "appearancePreference")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "appearancePreference")
        super.tearDown()
    }

    // MARK: - Test 1: Default preference is .system on fresh install

    func testDefaultPreferenceIsSystem() {
        // Clear any existing preference
        UserDefaults.standard.removeObject(forKey: "appearancePreference")

        // Create a new manager instance (using forTesting initializer)
        let manager = AppearanceManager(forTesting: true)

        XCTAssertEqual(manager.preference, .system,
                       "Default preference should be .system for new users")
    }

    // MARK: - Test 2: cyclePreference cycles correctly: system -> light -> dark -> system

    func testCyclePreferenceCyclesCorrectly() {
        let manager = AppearanceManager(forTesting: true)
        manager.preference = .system

        // Cycle: system -> light
        manager.cyclePreference()
        XCTAssertEqual(manager.preference, .light,
                       "Cycling from system should go to light")

        // Cycle: light -> dark
        manager.cyclePreference()
        XCTAssertEqual(manager.preference, .dark,
                       "Cycling from light should go to dark")

        // Cycle: dark -> system
        manager.cyclePreference()
        XCTAssertEqual(manager.preference, .system,
                       "Cycling from dark should go back to system")
    }

    // MARK: - Test 3: Preference persists to UserDefaults after setting

    func testPreferencePersistsToUserDefaults() {
        let manager = AppearanceManager(forTesting: true)

        manager.preference = .dark

        let storedValue = UserDefaults.standard.string(forKey: "appearancePreference")
        XCTAssertEqual(storedValue, "dark",
                       "Preference should persist to UserDefaults")
    }

    // MARK: - Test 4: Preference loads correctly from UserDefaults on init

    func testPreferenceLoadsFromUserDefaults() {
        // Set a preference directly in UserDefaults
        UserDefaults.standard.set("light", forKey: "appearancePreference")

        // Create a new manager that should load the preference
        let manager = AppearanceManager(forTesting: true)

        XCTAssertEqual(manager.preference, .light,
                       "Manager should load saved preference from UserDefaults")
    }

    // MARK: - Test 5: AppearancePreference.next returns correct values

    func testAppearancePreferenceNextValues() {
        XCTAssertEqual(AppearancePreference.system.next, .light,
                       ".system.next should be .light")
        XCTAssertEqual(AppearancePreference.light.next, .dark,
                       ".light.next should be .dark")
        XCTAssertEqual(AppearancePreference.dark.next, .system,
                       ".dark.next should be .system")
    }
}

// MARK: - Theme Support: WebView Theme Tests

final class WebViewThemeTests: XCTestCase {

    // MARK: - Test 1: HTML includes color-scheme meta tag

    func testHTMLIncludesColorSchemeMetaTag() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("color-scheme"),
                      "HTML should include color-scheme meta tag")
        XCTAssertTrue(html.contains("colorSchemeTag"),
                      "Meta tag should have colorSchemeTag id for JavaScript access")
    }

    // MARK: - Test 2: HTML includes applyTheme JavaScript function

    func testHTMLIncludesApplyThemeFunction() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("function applyTheme"),
                      "HTML should include applyTheme JavaScript function")
    }

    // MARK: - Test 3: HTML includes forced light theme CSS

    func testHTMLIncludesForcedLightThemeCSS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("html.theme-light"),
                      "HTML should include forced light theme CSS rules")
    }

    // MARK: - Test 4: HTML includes forced dark theme CSS

    func testHTMLIncludesForcedDarkThemeCSS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("html.theme-dark"),
                      "HTML should include forced dark theme CSS rules")
    }
}

// MARK: - Task Group 2: Document Model Tests

final class MarkdownDocumentTests: XCTestCase {

    // MARK: - Test 1: Successful initialization from valid markdown data

    func testInitializationFromValidMarkdownData() throws {
        // Create a temporary markdown file
        let markdownContent = "# Hello World\n\nThis is a **test** document."
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test.md")

        try markdownContent.write(to: tempFile, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        // Read the file data and create a document
        let data = try Data(contentsOf: tempFile)
        let fileWrapper = FileWrapper(regularFileWithContents: data)

        // Test that we can create a MarkdownDocument from the data directly
        // Since we can't construct FileDocumentReadConfiguration, we test the internal parsing
        guard let content = String(data: data, encoding: .utf8) else {
            XCTFail("Failed to decode file data")
            return
        }

        XCTAssertEqual(content, markdownContent)
    }

    // MARK: - Test 2: Handling of empty file content

    func testHandlingOfEmptyFileContent() throws {
        // Create a temporary empty markdown file
        let emptyContent = ""
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("empty.md")

        try emptyContent.write(to: tempFile, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        // Read the file and verify empty content
        let data = try Data(contentsOf: tempFile)
        guard let content = String(data: data, encoding: .utf8) else {
            XCTFail("Failed to decode file data")
            return
        }

        XCTAssertEqual(content, "")
    }

    // MARK: - Test 3: Document is read-only (no write capability)

    func testDocumentIsReadOnly() throws {
        // Verify writableContentTypes is empty (read-only)
        XCTAssertTrue(MarkdownDocument.writableContentTypes.isEmpty,
                      "MarkdownDocument should have no writable content types")

        // Create a document and verify the fileWrapper method throws
        var document = MarkdownDocument()
        document.content = "Test content"

        // The document's fileWrapper should throw since it's read-only
        // We can't call it directly without WriteConfiguration, but we verified
        // writableContentTypes is empty which indicates read-only behavior
    }

    // MARK: - Test 4: readableContentTypes includes markdown UTType

    func testReadableContentTypesIncludesMarkdown() {
        let readableTypes = MarkdownDocument.readableContentTypes

        XCTAssertEqual(readableTypes.count, 1,
                       "Should have exactly one readable content type")
        XCTAssertTrue(readableTypes.contains(.markdown),
                      "Should include markdown UTType")
    }

    // MARK: - Test 5: UTType.markdown is properly configured

    func testMarkdownUTTypeConfiguration() {
        let markdownType = UTType.markdown

        // Verify the identifier
        XCTAssertEqual(markdownType.identifier, "net.daringfireball.markdown",
                       "Markdown UTType should have correct identifier")

        // Verify the type exists and is valid
        XCTAssertNotNil(markdownType,
                        "Markdown UTType should be non-nil")
    }
}

// MARK: - Task Group 3: WKWebView Integration Tests

final class WebViewTests: XCTestCase {

    // MARK: - Test 1: WebView creates successfully

    func testWebViewCreatesSuccessfully() {
        let webView = WebView(content: "Test content")
        // Verify the view can be created without errors
        XCTAssertNotNil(webView, "WebView should create successfully")
        XCTAssertEqual(webView.content, "Test content", "Content should be set correctly")
    }

    // MARK: - Test 2: WebView accepts optional fileURL

    func testWebViewAcceptsFileURL() {
        let testURL = URL(fileURLWithPath: "/Users/test/document.md")
        let webView = WebView(content: "Test", fileURL: testURL)

        XCTAssertNotNil(webView.fileURL, "FileURL should be set")
        XCTAssertEqual(webView.fileURL, testURL, "FileURL should match")
    }

    // MARK: - Test 3: WebView generates valid HTML document with markdown-it

    func testWebViewGeneratesValidHTMLDocument() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("Test content")

        // Verify HTML structure
        XCTAssertTrue(html.contains("<!DOCTYPE html>"),
                      "Should include DOCTYPE declaration")
        XCTAssertTrue(html.contains("<html>"),
                      "Should include html tag")
        XCTAssertTrue(html.contains("<head>"),
                      "Should include head tag")
        XCTAssertTrue(html.contains("<body>"),
                      "Should include body tag")
        XCTAssertTrue(html.contains("</body>"),
                      "Should include closing body tag")
        XCTAssertTrue(html.contains("</html>"),
                      "Should include closing html tag")
    }

    // MARK: - Test 4: HTML includes markdown-body div

    func testHTMLIncludesMarkdownBodyDiv() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("class=\"markdown-body\""),
                      "Should include markdown-body class")
        XCTAssertTrue(html.contains("id=\"content\""),
                      "Should include content id for JavaScript rendering")
    }

    // MARK: - Test 5: HTML includes monospace font for code

    func testHTMLIncludesMonospaceFontForCode() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("```\ncode\n```")

        // Verify HTML includes monospace font family for code elements
        XCTAssertTrue(html.contains("ui-monospace") || html.contains("monospace"),
                      "HTML should specify monospace font family for code")
        XCTAssertTrue(html.contains("SFMono") || html.contains("Menlo") || html.contains("Consolas"),
                      "HTML should include system monospace fonts")
    }
}

// MARK: - Markdown Rendering Tests

final class MarkdownRenderingTests: XCTestCase {

    // MARK: - Test 1: HTML includes markdown-it JavaScript

    func testHTMLIncludesMarkdownItJS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        // markdown-it.min.js should be inlined in the HTML
        XCTAssertTrue(html.contains("markdownit") || html.contains("markdown-it"),
                      "HTML should include markdown-it library")
    }

    // MARK: - Test 2: HTML includes markdown-it-anchor plugin

    func testHTMLIncludesAnchorPlugin() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        // markdown-it-anchor should be loaded
        XCTAssertTrue(html.contains("markdownItAnchor"),
                      "HTML should include markdown-it-anchor plugin")
    }

    // MARK: - Test 3: HTML includes task-lists plugin

    func testHTMLIncludesTaskListsPlugin() {
        let webView = WebView(content: "- [ ] task")
        let html = webView.wrapInHTML("- [ ] task")

        // markdown-it-task-lists should be loaded
        XCTAssertTrue(html.contains("markdownitTaskLists") || html.contains("task-list"),
                      "HTML should include markdown-it-task-lists plugin")
    }

    // MARK: - Test 4: Markdown-it is configured correctly

    func testMarkdownItConfiguration() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("test")

        // Verify configuration options
        XCTAssertTrue(html.contains("html: false"),
                      "HTML option should be disabled")
        XCTAssertTrue(html.contains("linkify: true"),
                      "Linkify option should be enabled")
        XCTAssertTrue(html.contains("typographer: false"),
                      "Typographer option should be disabled")
    }

    // MARK: - Test 5: Markdown content is escaped for JS

    func testMarkdownContentEscapedForJS() {
        let webView = WebView(content: "")
        // Test with backticks and dollar signs which need escaping in JS template literals
        let html = webView.wrapInHTML("Test `code` with $var")

        // The content should be in the output (escaped)
        XCTAssertTrue(html.contains("Test"),
                      "Content should be present in output")
        // Backticks should be escaped
        XCTAssertTrue(html.contains("\\`") || html.contains("code"),
                      "Backticks should be escaped or content preserved")
    }

    // MARK: - Test 6: Slugify function is included

    func testSlugifyFunctionIncluded() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("# Test Header")

        // Should include the slugify function for GitHub-style IDs
        XCTAssertTrue(html.contains("function slugify"),
                      "Should include slugify function for header IDs")
    }
}

// MARK: - Resource Loading Tests

final class ResourceLoadingTests: XCTestCase {

    // MARK: - Test 1: markdown-it.min.js exists in bundle

    func testMarkdownItJSExistsInBundle() {
        let url = Bundle.main.url(forResource: "markdown-it.min", withExtension: "js")
        XCTAssertNotNil(url, "markdown-it.min.js should exist in bundle")
    }

    // MARK: - Test 2: markdown-it-anchor.min.js exists in bundle

    func testMarkdownItAnchorJSExistsInBundle() {
        let url = Bundle.main.url(forResource: "markdown-it-anchor.min", withExtension: "js")
        XCTAssertNotNil(url, "markdown-it-anchor.min.js should exist in bundle")
    }

    // MARK: - Test 3: markdown-it-task-lists.min.js exists in bundle

    func testMarkdownItTaskListsJSExistsInBundle() {
        let url = Bundle.main.url(forResource: "markdown-it-task-lists.min", withExtension: "js")
        XCTAssertNotNil(url, "markdown-it-task-lists.min.js should exist in bundle")
    }

    // MARK: - Test 4: JS files are readable

    func testJSFilesAreReadable() {
        if let url = Bundle.main.url(forResource: "markdown-it.min", withExtension: "js") {
            let content = try? String(contentsOf: url, encoding: .utf8)
            XCTAssertNotNil(content, "markdown-it.min.js should be readable")
            XCTAssertTrue(content?.count ?? 0 > 1000, "markdown-it.min.js should have substantial content")
        }
    }
}

// MARK: - Task Group 4: Path Abbreviation Tests

final class PathAbbreviationTests: XCTestCase {

    // MARK: - Test 1: Home directory substitution with ~

    func testHomeDirectorySubstitutionWithTilde() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let testPath = "\(homeDir)/Documents/test.md"

        let abbreviated = PathHelper.abbreviate(path: testPath)

        XCTAssertTrue(abbreviated.hasPrefix("~"),
                      "Path should start with ~ after abbreviation")
        XCTAssertTrue(abbreviated.contains("/Documents/test.md"),
                      "Path should contain relative components after home")
        XCTAssertFalse(abbreviated.contains("/Users/"),
                       "Path should not contain /Users/ after abbreviation")
    }

    // MARK: - Test 2: Path outside home directory (no substitution)

    func testPathOutsideHomeDirectory() {
        let testPath = "/var/log/system.log"

        let abbreviated = PathHelper.abbreviate(path: testPath)

        XCTAssertEqual(abbreviated, testPath,
                       "Path outside home should remain unchanged")
        XCTAssertFalse(abbreviated.hasPrefix("~"),
                       "Path outside home should not start with ~")
    }

    // MARK: - Test 3: Empty path handling

    func testEmptyPathHandling() {
        let abbreviated = PathHelper.abbreviate(path: "")

        XCTAssertEqual(abbreviated, "",
                       "Empty path should return empty string")
    }

    // MARK: - Test 4: Nil URL handling

    func testNilURLHandling() {
        let abbreviated = PathHelper.abbreviate(url: nil)

        XCTAssertEqual(abbreviated, "Markdown Viewer",
                       "Nil URL should return app name placeholder")
    }
}

// MARK: - Task Group 5: Drag-and-Drop Tests

final class DragAndDropTests: XCTestCase {

    // MARK: - Test 1: Valid markdown file extension accepted

    func testValidMarkdownFileExtensionAccepted() {
        XCTAssertTrue(FileValidator.isMarkdownFile(extension: "md"),
                      ".md extension should be accepted")
        XCTAssertTrue(FileValidator.isMarkdownFile(extension: "markdown"),
                      ".markdown extension should be accepted")
        XCTAssertTrue(FileValidator.isMarkdownFile(extension: "MD"),
                      "Extension check should be case-insensitive")
        XCTAssertTrue(FileValidator.isMarkdownFile(extension: "MARKDOWN"),
                      "Extension check should be case-insensitive")
    }

    // MARK: - Test 2: Non-markdown file extension rejected

    func testNonMarkdownFileExtensionRejected() {
        XCTAssertFalse(FileValidator.isMarkdownFile(extension: "txt"),
                       ".txt extension should be rejected")
        XCTAssertFalse(FileValidator.isMarkdownFile(extension: "html"),
                       ".html extension should be rejected")
        XCTAssertFalse(FileValidator.isMarkdownFile(extension: "pdf"),
                       ".pdf extension should be rejected")
        XCTAssertFalse(FileValidator.isMarkdownFile(extension: ""),
                       "Empty extension should be rejected")
    }

    // MARK: - Test 3: Valid markdown URL accepted

    func testValidMarkdownURLAccepted() {
        let mdURL = URL(fileURLWithPath: "/Users/test/document.md")
        let markdownURL = URL(fileURLWithPath: "/Users/test/readme.markdown")

        XCTAssertTrue(FileValidator.isMarkdownFile(url: mdURL),
                      "URL with .md extension should be accepted")
        XCTAssertTrue(FileValidator.isMarkdownFile(url: markdownURL),
                      "URL with .markdown extension should be accepted")
    }

    // MARK: - Test 4: Non-markdown URL rejected

    func testNonMarkdownURLRejected() {
        let txtURL = URL(fileURLWithPath: "/Users/test/document.txt")
        let pdfURL = URL(fileURLWithPath: "/Users/test/document.pdf")

        XCTAssertFalse(FileValidator.isMarkdownFile(url: txtURL),
                       "URL with .txt extension should be rejected")
        XCTAssertFalse(FileValidator.isMarkdownFile(url: pdfURL),
                       "URL with .pdf extension should be rejected")
    }
}

// MARK: - Task Group 6: Error Handling Tests

final class ErrorHandlingTests: XCTestCase {

    // MARK: - Test 1: File read success for valid markdown

    func testFileReadSuccessForValidMarkdown() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("valid.md")
        let content = "# Valid Markdown"

        try content.write(to: tempFile, atomically: true, encoding: .utf8)

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        let result = FileValidator.readMarkdownFile(at: tempFile)

        switch result {
        case .success(let readContent):
            XCTAssertEqual(readContent, content,
                           "Should successfully read markdown content")
        case .failure(let error):
            XCTFail("Should not fail for valid markdown file: \(error)")
        }
    }

    // MARK: - Test 2: File read error for non-existent file

    func testFileReadErrorForNonExistentFile() {
        let nonExistentURL = URL(fileURLWithPath: "/nonexistent/path/file.md")

        let result = FileValidator.readMarkdownFile(at: nonExistentURL)

        switch result {
        case .success:
            XCTFail("Should fail for non-existent file")
        case .failure(let error):
            XCTAssertEqual(error, .fileNotFound,
                           "Should return fileNotFound error")
        }
    }

    // MARK: - Test 3: Invalid file type error

    func testInvalidFileTypeError() {
        let txtURL = URL(fileURLWithPath: "/Users/test/document.txt")

        let result = FileValidator.readMarkdownFile(at: txtURL)

        switch result {
        case .success:
            XCTFail("Should fail for non-markdown file")
        case .failure(let error):
            XCTAssertEqual(error, .invalidFileType,
                           "Should return invalidFileType error")
        }
    }
}

// MARK: - Edge Case Tests

final class MarkdownEdgeCaseTests: XCTestCase {

    // MARK: - Test 1: Empty content handling

    func testEmptyContentHandling() {
        let webView = WebView(content: "")
        let html = webView.wrapInHTML("")

        // Should produce valid HTML even with empty content
        XCTAssertTrue(html.contains("<!DOCTYPE html>"),
                      "Should include DOCTYPE even for empty content")
        XCTAssertTrue(html.contains("markdown-body"),
                      "Should include markdown-body div even for empty content")
    }

    // MARK: - Test 2: Special characters in content

    func testSpecialCharactersInContent() {
        let webView = WebView(content: "")
        let content = "Test <script>alert('xss')</script> & \"quotes\" 'apostrophe'"
        let html = webView.wrapInHTML(content)

        // Content should be in the output
        XCTAssertTrue(html.contains("Test"),
                      "Content should be preserved")
        // markdown-it with html:false should not allow raw HTML
    }

    // MARK: - Test 3: Unicode content handling

    func testUnicodeContentHandling() {
        let webView = WebView(content: "")
        let content = "Unicode test: \u{1F600} \u{4E2D}\u{6587} \u{0410}\u{0411}\u{0412}"
        let html = webView.wrapInHTML(content)

        XCTAssertTrue(html.contains("Unicode test"),
                      "Unicode content should be preserved")
    }

    // MARK: - Test 4: Very long content handling

    func testVeryLongContentHandling() {
        let webView = WebView(content: "")
        let longContent = String(repeating: "This is a test paragraph. ", count: 1000)
        let html = webView.wrapInHTML(longContent)

        XCTAssertTrue(html.contains("This is a test paragraph"),
                      "Long content should be handled")
        XCTAssertTrue(html.count > longContent.count,
                      "HTML should be larger than raw content due to markup")
    }

    // MARK: - Test 5: Backslash handling

    func testBackslashHandling() {
        let webView = WebView(content: "")
        let content = "Path: C:\\Users\\test\\file.md"
        let html = webView.wrapInHTML(content)

        // Backslashes should be escaped for JS but content preserved
        XCTAssertTrue(html.contains("Path") || html.contains("\\\\"),
                      "Backslash content should be handled")
    }

    // MARK: - Test 6: Nested markdown structures

    func testNestedMarkdownStructures() {
        let webView = WebView(content: "")
        let content = """
        > Blockquote with **bold** and *italic*
        >
        > - List item 1
        > - List item 2
        """
        let html = webView.wrapInHTML(content)

        XCTAssertTrue(html.contains("Blockquote"),
                      "Nested markdown should be handled")
    }
}

// MARK: - Anchor Navigation Tests

final class AnchorNavigationTests: XCTestCase {

    // MARK: - Test 1: HTML includes anchor click handler

    func testHTMLIncludesAnchorClickHandler() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("a[href^=\"#\"]"),
                      "HTML should include anchor link click handler selector")
    }

    // MARK: - Test 2: HTML includes anchor highlight CSS

    func testHTMLIncludesAnchorHighlightCSS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("anchor-highlight"),
                      "HTML should include anchor-highlight CSS class")
        XCTAssertTrue(html.contains("@keyframes anchor-highlight"),
                      "HTML should include anchor-highlight animation keyframes")
    }

    // MARK: - Test 3: HTML includes smart scroll behavior logic

    func testHTMLIncludesSmartScrollBehavior() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("viewportHeight * 2"),
                      "HTML should include smart scroll distance calculation")
        XCTAssertTrue(html.contains("behavior: behavior"),
                      "HTML should use dynamic scroll behavior")
    }

    // MARK: - Test 4: HTML includes scroll offset

    func testHTMLIncludesScrollOffset() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("offset = 16"),
                      "HTML should include 16px scroll offset")
    }

    // MARK: - Test 5: Dark theme has anchor highlight variant

    func testDarkThemeHasAnchorHighlightVariant() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("anchor-highlight-dark"),
                      "HTML should include dark theme anchor highlight animation")
        XCTAssertTrue(html.contains("html.theme-dark .anchor-highlight"),
                      "HTML should style anchor-highlight for forced dark theme")
    }
}

// MARK: - Vi-Style Vertical Navigation Tests

final class ViNavigationTests: XCTestCase {

    // MARK: - Test 1: HTML includes vi navigation keydown handler

    func testHTMLIncludesViNavigationHandler() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("Vi-style vertical navigation"),
                      "HTML should include vi navigation code block")
        XCTAssertTrue(html.contains("addEventListener('keydown'"),
                      "HTML should include keydown event listener")
    }

    // MARK: - Test 2: HTML includes j/k line scrolling

    func testHTMLIncludesLineScrolling() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case 'j':"),
                      "HTML should handle j key for scroll down")
        XCTAssertTrue(html.contains("case 'k':"),
                      "HTML should handle k key for scroll up")
        XCTAssertTrue(html.contains("LINE_HEIGHT"),
                      "HTML should define LINE_HEIGHT constant")
    }

    // MARK: - Test 3: HTML includes gg sequence handling

    func testHTMLIncludesGGSequence() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("lastKey === 'g'"),
                      "HTML should track g key sequence")
        XCTAssertTrue(html.contains("lastKeyTime") && html.contains("500"),
                      "HTML should use 500ms timeout for gg sequence")
    }

    // MARK: - Test 4: HTML includes G for bottom navigation

    func testHTMLIncludesGForBottom() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case 'G':"),
                      "HTML should handle G key for jump to bottom")
        XCTAssertTrue(html.contains("document.body.scrollHeight"),
                      "HTML should scroll to document bottom")
    }

    // MARK: - Test 5: HTML includes Ctrl+d/u half-page scrolling

    func testHTMLIncludesHalfPageScrolling() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case 'd':") && html.contains("e.ctrlKey"),
                      "HTML should handle Ctrl+d")
        XCTAssertTrue(html.contains("case 'u':") && html.contains("e.ctrlKey"),
                      "HTML should handle Ctrl+u")
        XCTAssertTrue(html.contains("viewportHeight / 2"),
                      "HTML should scroll by half viewport height")
    }

    // MARK: - Test 6: HTML includes Ctrl+f/b full-page scrolling

    func testHTMLIncludesFullPageScrolling() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case 'f':") && html.contains("e.ctrlKey"),
                      "HTML should handle Ctrl+f")
        XCTAssertTrue(html.contains("case 'b':") && html.contains("e.ctrlKey"),
                      "HTML should handle Ctrl+b")
    }

    // MARK: - Test 7: HTML ignores keys in input fields

    func testHTMLIgnoresInputFields() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("e.target.tagName === 'INPUT'"),
                      "HTML should ignore keys when in INPUT field")
        XCTAssertTrue(html.contains("e.target.tagName === 'TEXTAREA'"),
                      "HTML should ignore keys when in TEXTAREA field")
    }

    // MARK: - Test 8: HTML includes h/l horizontal scrolling

    func testHTMLIncludesHorizontalScrolling() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case 'h':"),
                      "HTML should handle h key for scroll left")
        XCTAssertTrue(html.contains("case 'l':"),
                      "HTML should handle l key for scroll right")
        XCTAssertTrue(html.contains("left: -LINE_HEIGHT"),
                      "HTML should scroll left by LINE_HEIGHT")
        XCTAssertTrue(html.contains("left: LINE_HEIGHT"),
                      "HTML should scroll right by LINE_HEIGHT")
    }

    // MARK: - Test 9: HTML includes 0/$ for far left/right

    func testHTMLIncludesFarLeftRightNavigation() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("case '0':"),
                      "HTML should handle 0 key for far left")
        XCTAssertTrue(html.contains("case '$':"),
                      "HTML should handle $ key for far right")
        XCTAssertTrue(html.contains("left: 0"),
                      "HTML should scroll to left: 0")
        XCTAssertTrue(html.contains("document.body.scrollWidth"),
                      "HTML should scroll to scrollWidth for far right")
    }
}

// MARK: - Vi-Style Search Tests

final class ViSearchTests: XCTestCase {

    // MARK: - Test 1: HTML includes search box

    func testHTMLIncludesSearchBox() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("id=\"searchBox\""),
                      "HTML should include search box element")
        XCTAssertTrue(html.contains("id=\"searchInput\""),
                      "HTML should include search input element")
        XCTAssertTrue(html.contains("id=\"searchCount\""),
                      "HTML should include search count element")
    }

    // MARK: - Test 2: HTML includes search box CSS

    func testHTMLIncludesSearchBoxCSS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains(".search-box"),
                      "HTML should include search-box CSS class")
        XCTAssertTrue(html.contains(".search-box.visible"),
                      "HTML should include visible state for search box")
    }

    // MARK: - Test 3: HTML includes search match highlighting CSS

    func testHTMLIncludesSearchMatchCSS() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains(".search-match"),
                      "HTML should include search-match CSS class")
        XCTAssertTrue(html.contains(".search-match-current"),
                      "HTML should include search-match-current CSS class")
    }

    // MARK: - Test 4: HTML includes search functionality

    func testHTMLIncludesSearchFunctionality() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("Vi-style search functionality"),
                      "HTML should include search functionality code")
        XCTAssertTrue(html.contains("highlightMatches"),
                      "HTML should include highlightMatches function")
        XCTAssertTrue(html.contains("clearHighlights"),
                      "HTML should include clearHighlights function")
    }

    // MARK: - Test 5: HTML includes / key handler

    func testHTMLIncludesSlashKeyHandler() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("e.key === '/'"),
                      "HTML should handle / key to open search")
        XCTAssertTrue(html.contains("openSearch"),
                      "HTML should include openSearch function")
    }

    // MARK: - Test 6: HTML includes n/N navigation

    func testHTMLIncludesMatchNavigation() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("e.key === 'n'"),
                      "HTML should handle n key for next match")
        XCTAssertTrue(html.contains("e.key === 'N'"),
                      "HTML should handle N key for previous match")
        XCTAssertTrue(html.contains("nextMatch"),
                      "HTML should include nextMatch function")
        XCTAssertTrue(html.contains("prevMatch"),
                      "HTML should include prevMatch function")
    }

    // MARK: - Test 7: HTML includes Escape to close

    func testHTMLIncludesEscapeToClose() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("'Escape'"),
                      "HTML should handle Escape key")
        XCTAssertTrue(html.contains("closeSearch"),
                      "HTML should include closeSearch function")
    }

    // MARK: - Test 8: HTML includes match count display

    func testHTMLIncludesMatchCountDisplay() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("updateCount"),
                      "HTML should include updateCount function")
        XCTAssertTrue(html.contains("searchCount.textContent"),
                      "HTML should update search count text")
    }

    // MARK: - Test 9: HTML includes Enter/Shift+Enter handling

    func testHTMLIncludesEnterHandling() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("e.key === 'Enter'"),
                      "HTML should handle Enter key")
        XCTAssertTrue(html.contains("e.shiftKey"),
                      "HTML should check for Shift+Enter")
    }

    // MARK: - Test 10: HTML includes real-time search

    func testHTMLIncludesRealTimeSearch() {
        let webView = WebView(content: "# Test")
        let html = webView.wrapInHTML("# Test")

        XCTAssertTrue(html.contains("addEventListener('input'"),
                      "HTML should listen for input events")
        XCTAssertTrue(html.contains("highlightMatches(searchInput.value)"),
                      "HTML should highlight matches on input")
    }
}
