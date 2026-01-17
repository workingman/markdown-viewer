import SwiftUI
import AppKit

@main
struct MarkdownViewerApp: App {
    /// Shared appearance manager for global theme preference
    @StateObject private var appearanceManager = AppearanceManager.shared

    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            ContentView(document: file.document, fileURL: file.fileURL)
                .environmentObject(appearanceManager)
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            // MARK: - File Menu
            // Remove "New" item (read-only viewer, only Open makes sense)
            CommandGroup(replacing: .newItem) { }

            CommandGroup(replacing: .printItem) {
                Button("Print...") {
                    NotificationCenter.default.post(name: .printDocument, object: nil)
                }
                .keyboardShortcut("p", modifiers: .command)
            }

            // MARK: - Edit Menu (Find)
            CommandGroup(after: .textEditing) {
                Button("Find...") {
                    NotificationCenter.default.post(name: .openFind, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }

            // MARK: - View Menu
            CommandGroup(after: .toolbar) {
                // Refresh
                Button("Refresh") {
                    NotificationCenter.default.post(name: .refreshDocument, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                // Appearance submenu
                Picker("Appearance", selection: $appearanceManager.preference) {
                    Text("System").tag(AppearancePreference.system)
                    Text("Light").tag(AppearancePreference.light)
                    Text("Dark").tag(AppearancePreference.dark)
                }
                .pickerStyle(.inline)

                // Cycle Appearance
                Button("Cycle Appearance") {
                    appearanceManager.cyclePreference()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])

                Divider()

                // Zoom controls
                Button("Actual Size") {
                    NotificationCenter.default.post(name: .zoomActualSize, object: nil)
                }
                .keyboardShortcut("0", modifiers: .command)

                Button("Zoom In") {
                    NotificationCenter.default.post(name: .zoomIn, object: nil)
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    NotificationCenter.default.post(name: .zoomOut, object: nil)
                }
                .keyboardShortcut("-", modifiers: .command)
            }

            // MARK: - Help Menu
            CommandGroup(replacing: .help) {
                Button("Keyboard Shortcuts") {
                    NotificationCenter.default.post(name: .showKeyboardShortcuts, object: nil)
                }
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let printDocument = Notification.Name("printDocument")
    static let openFind = Notification.Name("openFind")
    static let zoomActualSize = Notification.Name("zoomActualSize")
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let showKeyboardShortcuts = Notification.Name("showKeyboardShortcuts")
}
