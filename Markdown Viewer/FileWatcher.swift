import Foundation
import Combine

/// Monitors a file for changes using polling
/// Publishes updates when the file's modification date changes
final class FileWatcher: ObservableObject {
    /// Published when the file content changes
    @Published private(set) var lastModified: Date?

    /// The URL being watched
    private(set) var fileURL: URL?

    /// Timer for polling
    private var timer: Timer?

    /// Polling interval in seconds
    private let pollInterval: TimeInterval = 1.0

    /// Last known modification date
    private var lastKnownModificationDate: Date?

    /// Start watching a file for changes
    /// - Parameter url: The file URL to watch
    func watch(_ url: URL?) {
        // Stop any existing watcher
        stop()

        guard let url = url else {
            fileURL = nil
            return
        }

        fileURL = url
        lastKnownModificationDate = getModificationDate(for: url)
        lastModified = lastKnownModificationDate

        // Start polling timer on main thread
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    /// Stop watching the current file
    func stop() {
        timer?.invalidate()
        timer = nil
        fileURL = nil
        lastKnownModificationDate = nil
    }

    /// Check if the file has been modified
    private func checkForChanges() {
        guard let url = fileURL else { return }

        let currentModificationDate = getModificationDate(for: url)

        // Only trigger if modification date actually changed
        if let current = currentModificationDate,
           let last = lastKnownModificationDate,
           current > last {
            lastKnownModificationDate = current
            DispatchQueue.main.async { [weak self] in
                self?.lastModified = current
            }
        } else if currentModificationDate != nil && lastKnownModificationDate == nil {
            // File was created or became accessible
            lastKnownModificationDate = currentModificationDate
            DispatchQueue.main.async { [weak self] in
                self?.lastModified = currentModificationDate
            }
        }
    }

    /// Get the modification date for a file
    /// - Parameter url: The file URL
    /// - Returns: The modification date, or nil if unavailable
    private func getModificationDate(for url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.modificationDate] as? Date
        } catch {
            return nil
        }
    }

    deinit {
        stop()
    }
}
