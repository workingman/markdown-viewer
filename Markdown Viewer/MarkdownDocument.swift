import SwiftUI
import UniformTypeIdentifiers

/// A read-only document model for markdown files
/// Conforms to FileDocument protocol for use with DocumentGroup
struct MarkdownDocument: FileDocument {
    /// The raw markdown content as a string
    var content: String

    /// Supported content types for reading
    /// Uses the markdown UTType which supports .md and .markdown extensions
    static var readableContentTypes: [UTType] { [.markdown] }

    /// This document is read-only, so we don't support writing
    static var writableContentTypes: [UTType] { [] }

    /// Initialize with empty content (for new documents)
    init() {
        self.content = ""
    }

    /// Initialize from file data
    /// - Parameter configuration: The read configuration containing file data
    /// - Throws: CocoaError if the file cannot be read as UTF-8 text
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        // Attempt to decode as UTF-8, fall back to other encodings
        if let text = String(data: data, encoding: .utf8) {
            self.content = text
        } else if let text = String(data: data, encoding: .isoLatin1) {
            self.content = text
        } else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
    }

    /// Write document to file wrapper
    /// This document is read-only, so this method throws an error
    /// - Parameter configuration: The write configuration
    /// - Returns: Never returns successfully
    /// - Throws: Always throws as this is a read-only document
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // This is a read-only document viewer, writing is not supported
        throw CocoaError(.fileWriteNoPermission)
    }
}
