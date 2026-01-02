import Foundation
import UniformTypeIdentifiers

/// Errors that can occur during file validation and reading
enum FileValidationError: Error, Equatable {
    case invalidFileType
    case fileNotFound
    case readError(String)

    static func == (lhs: FileValidationError, rhs: FileValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFileType, .invalidFileType):
            return true
        case (.fileNotFound, .fileNotFound):
            return true
        case (.readError(let lhsMsg), .readError(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

/// Validates files for markdown compatibility
enum FileValidator {
    /// Valid markdown file extensions (lowercase)
    private static let validExtensions = ["md", "markdown"]

    /// Checks if a file extension is a valid markdown extension
    /// - Parameter extension: The file extension to check (without leading dot)
    /// - Returns: True if the extension is valid for markdown files
    static func isMarkdownFile(extension ext: String) -> Bool {
        validExtensions.contains(ext.lowercased())
    }

    /// Checks if a URL points to a valid markdown file based on extension
    /// - Parameter url: The file URL to check
    /// - Returns: True if the URL has a valid markdown extension
    static func isMarkdownFile(url: URL) -> Bool {
        isMarkdownFile(extension: url.pathExtension)
    }

    /// Reads a markdown file and returns its contents
    /// - Parameter url: The file URL to read
    /// - Returns: Result containing the file contents or an error
    static func readMarkdownFile(at url: URL) -> Result<String, FileValidationError> {
        // First check if it's a markdown file
        guard isMarkdownFile(url: url) else {
            return .failure(.invalidFileType)
        }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .failure(.fileNotFound)
        }

        // Try to read the file
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return .success(content)
        } catch {
            return .failure(.readError(error.localizedDescription))
        }
    }
}
