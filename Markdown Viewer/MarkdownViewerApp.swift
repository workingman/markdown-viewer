import SwiftUI

@main
struct MarkdownViewerApp: App {
    /// Shared appearance manager for global theme preference
    @StateObject private var appearanceManager = AppearanceManager.shared

    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            ContentView(document: file.$document, fileURL: file.fileURL)
                .environmentObject(appearanceManager)
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            // View > Appearance submenu
            CommandGroup(after: .toolbar) {
                // Appearance submenu with Picker for checkmark behavior
                Picker("Appearance", selection: $appearanceManager.preference) {
                    Text("System").tag(AppearancePreference.system)
                    Text("Light").tag(AppearancePreference.light)
                    Text("Dark").tag(AppearancePreference.dark)
                }
                .pickerStyle(.inline)

                Divider()

                // Cycle Appearance menu item with Cmd+Shift+T shortcut
                Button("Cycle Appearance") {
                    appearanceManager.cyclePreference()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}
