# SwiftUI/macOS App Learnings

Lessons learned while building the Markdown Viewer macOS app.

## Xcode Build System

### Entitlements file changes require clean build

**Problem:** After editing the `.entitlements` file, the build fails with:
```
error: Entitlements file "X.entitlements" was modified during the build, which is not supported.
```

**Cause:** Xcode caches the entitlements file during the build process. If you modify it while a build is in progress or between incremental builds, Xcode detects the mismatch.

**Solution:** Always do a clean build after modifying entitlements:
```bash
xcodebuild -project "Project.xcodeproj" -scheme "Scheme" clean build
```

Or in Xcode: Product > Clean Build Folder (Cmd+Shift+K), then build.

## Sandbox and File Access

### Problem: Document-based app shows blank content with sandbox enabled

**Symptoms:**
- Window opens and shows filename in title bar
- Content area is blank
- No errors displayed
- `FileDocument.init(configuration:)` never called

**Root Cause:**
The default sandbox entitlements (`com.apple.security.files.user-selected.read-only`) were not sufficient for the DocumentGroup to read files opened via `open -a "App" file.md` or double-clicking.

**Solution:**
Disable sandbox during development by setting `com.apple.security.app-sandbox` to `false` in the entitlements file. For production, additional entitlements may be needed:
- `com.apple.security.files.bookmarks.app-scope` for file bookmarks
- Possibly `com.apple.security.files.user-selected.read-write` for full access

**Debugging tip:**
When sandbox blocks file operations, there are no visible errors. Use `print()` statements to verify if code paths are being executed, but note that sandbox also blocks writing to `/tmp` for debug files.

## WKWebView in SwiftUI

### NSViewRepresentable Pattern

When wrapping WKWebView for SwiftUI:

```swift
struct WebView: NSViewRepresentable {
    let content: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let html = wrapInHTML(content)
        webView.loadHTMLString(html, baseURL: nil)
        context.coordinator.lastContent = content
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Only reload if content changed to prevent flicker
        guard content != context.coordinator.lastContent else { return }
        context.coordinator.lastContent = content
        let html = wrapInHTML(content)
        nsView.loadHTMLString(html, baseURL: nil)
    }

    class Coordinator {
        var lastContent: String = ""
    }
}
```

**Key points:**
- Use a Coordinator to track state between updates
- Check if content actually changed before reloading to prevent unnecessary reloads
- Load initial content in `makeNSView`, not just `updateNSView`

## DocumentGroup for Read-Only Documents

### Using `viewing:` mode

For read-only document viewers, use `DocumentGroup(viewing:)`:

```swift
DocumentGroup(viewing: MarkdownDocument.self) { file in
    ContentView(document: file.$document, fileURL: file.fileURL)
}
```

This automatically:
- Adds File > Open menu
- Handles recent documents
- Creates windows per document
- Passes file URL for title display

### FileDocument for Read-Only

```swift
struct MarkdownDocument: FileDocument {
    var content: String

    static var readableContentTypes: [UTType] { [.markdown] }
    static var writableContentTypes: [UTType] { [] }  // Empty for read-only

    init() { self.content = "" }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
        self.content = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.fileWriteNoPermission)  // Read-only
    }
}
```

## UTType Configuration

### Info.plist for Markdown Files

Need both `CFBundleDocumentTypes` and `UTImportedTypeDeclarations`:

```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>Markdown Document</string>
        <key>CFBundleTypeRole</key>
        <string>Viewer</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>net.daringfireball.markdown</string>
        </array>
    </dict>
</array>

<key>UTImportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>
        <string>net.daringfireball.markdown</string>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.text</string>
        </array>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>md</string>
                <string>markdown</string>
            </array>
        </dict>
    </dict>
</array>
```

### Swift UTType Extension

```swift
extension UTType {
    static var markdown: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}
```

Use `importedAs:` for types declared in Info.plist's `UTImportedTypeDeclarations`.
