import Foundation

/// Helper for path manipulation, particularly abbreviating paths with ~
enum PathHelper {
    /// Abbreviates a file path by replacing the home directory with ~
    /// - Parameter path: The full file path to abbreviate
    /// - Returns: The abbreviated path string
    static func abbreviate(path: String) -> String {
        guard !path.isEmpty else {
            return ""
        }
        return (path as NSString).abbreviatingWithTildeInPath
    }

    /// Abbreviates a URL's path by replacing the home directory with ~
    /// - Parameter url: The file URL to abbreviate (optional)
    /// - Returns: The abbreviated path string, or app name placeholder if nil
    static func abbreviate(url: URL?) -> String {
        guard let url = url else {
            return "Markdown Viewer"
        }
        return abbreviate(path: url.path)
    }
}
