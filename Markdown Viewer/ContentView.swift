import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: MarkdownDocument

    /// The current file URL (from DocumentGroup or from drag-drop)
    @State var currentFileURL: URL?

    /// Tracks whether a valid file is being dragged over the drop zone
    @State private var isTargeted = false

    /// Controls the display of error alerts
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    /// Appearance manager from environment
    @EnvironmentObject var appearanceManager: AppearanceManager

    /// Initialize with document binding and optional file URL
    init(document: Binding<MarkdownDocument>, fileURL: URL? = nil) {
        self._document = document
        self._currentFileURL = State(initialValue: fileURL)
    }

    var body: some View {
        ZStack {
            WebView(content: document.content, fileURL: currentFileURL)
                .environmentObject(appearanceManager)
                .frame(minWidth: 800, minHeight: 600)
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
                    document.content = content
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
    ContentView(document: .constant(MarkdownDocument()))
        .environmentObject(AppearanceManager.shared)
}
