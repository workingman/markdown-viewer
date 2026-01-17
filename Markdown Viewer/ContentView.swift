import SwiftUI
import UniformTypeIdentifiers

/// Notification for refreshing the current document
extension Notification.Name {
    static let refreshDocument = Notification.Name("refreshDocument")
}

struct ContentView: View {
    /// The document content (read-only, no binding to avoid dirty flag issues)
    let document: MarkdownDocument

    /// The displayed content (can be updated on drag-drop without affecting document dirty state)
    @State private var displayedContent: String

    /// The current file URL (from DocumentGroup or from drag-drop)
    @State var currentFileURL: URL?

    /// Tracks whether a valid file is being dragged over the drop zone
    @State private var isTargeted = false

    /// Controls the display of error alerts
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    /// Appearance manager from environment
    @EnvironmentObject var appearanceManager: AppearanceManager

    /// File watcher for live reload
    @StateObject private var fileWatcher = FileWatcher()

    /// Trigger for scroll position preservation during reload
    @State private var preserveScrollOnReload = false

    /// Initialize with document and optional file URL
    init(document: MarkdownDocument, fileURL: URL? = nil) {
        self.document = document
        self._displayedContent = State(initialValue: document.content)
        self._currentFileURL = State(initialValue: fileURL)
    }

    var body: some View {
        ZStack {
            WebView(content: displayedContent, fileURL: currentFileURL, preserveScroll: preserveScrollOnReload)
                .environmentObject(appearanceManager)
                .frame(minWidth: 400, minHeight: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Drop zone overlay for visual feedback
            if isTargeted {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 3)
                    .background(Color.accentColor.opacity(0.1))
                    .padding(8)
            }
        }
        .navigationTitle(PathHelper.abbreviate(url: currentFileURL))
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .alert("Invalid File", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Start watching the file when view appears
            fileWatcher.watch(currentFileURL)
        }
        .onDisappear {
            // Stop watching when view disappears
            fileWatcher.stop()
        }
        .onChange(of: currentFileURL) { newURL in
            // Update watcher when file changes (e.g., drag-drop)
            fileWatcher.watch(newURL)
        }
        .onReceive(fileWatcher.$lastModified) { _ in
            // Reload content when file changes
            reloadContent()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshDocument)) { _ in
            reloadContent()
        }
    }

    /// Reloads the content from the current file
    private func reloadContent() {
        guard let url = currentFileURL else { return }

        let result = FileValidator.readMarkdownFile(at: url)
        switch result {
        case .success(let content):
            // Only update if content actually changed
            if content != displayedContent {
                preserveScrollOnReload = true
                displayedContent = content
                // Reset flag after a brief delay to allow WebView to process
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    preserveScrollOnReload = false
                }
            }
        case .failure:
            // Silently ignore reload failures (file might be temporarily unavailable)
            break
        }
    }

    /// Handles file drop operations
    /// - Parameter providers: The item providers from the drop operation
    /// - Returns: True if the drop was handled, false otherwise
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    showError("Could not read the dropped file.")
                    return
                }

                // Validate that it's a markdown file
                guard FileValidator.isMarkdownFile(url: url) else {
                    showError("Not a markdown file. Please drop a .md or .markdown file.")
                    return
                }

                // Read the file content
                let result = FileValidator.readMarkdownFile(at: url)
                switch result {
                case .success(let content):
                    displayedContent = content
                    currentFileURL = url
                case .failure(let validationError):
                    switch validationError {
                    case .fileNotFound:
                        showError("The file could not be found.")
                    case .invalidFileType:
                        showError("Not a markdown file. Please drop a .md or .markdown file.")
                    case .readError(let message):
                        showError("Could not read the file: \(message)")
                    }
                }
            }
        }
        return true
    }

    /// Shows an error alert with the given message
    /// - Parameter message: The error message to display
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

#Preview {
    ContentView(document: MarkdownDocument())
        .environmentObject(AppearanceManager.shared)
}
