import SwiftUI

/// Represents the user's appearance preference for the markdown viewer
/// - system: follows macOS appearance automatically
/// - light: forces light theme regardless of system setting
/// - dark: forces dark theme regardless of system setting
enum AppearancePreference: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    /// Returns the next preference in the cycle order: system -> light -> dark -> system
    var next: AppearancePreference {
        switch self {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }
}

/// Manages appearance preference storage and change notifications
/// Uses UserDefaults for persistence and publishes changes for SwiftUI observation
class AppearanceManager: ObservableObject {
    /// Shared singleton instance for global preference management
    static let shared = AppearanceManager()

    /// UserDefaults key for storing the appearance preference
    private let key = "appearancePreference"

    /// The current appearance preference, persisted to UserDefaults on change
    @Published var preference: AppearancePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: key)
        }
    }

    /// Private initializer to enforce singleton pattern
    /// Loads saved preference from UserDefaults or defaults to .system
    private init() {
        let stored = UserDefaults.standard.string(forKey: key) ?? "system"
        self.preference = AppearancePreference(rawValue: stored) ?? .system
    }

    /// Initializer for testing purposes that allows creating non-shared instances
    /// - Parameter forTesting: pass true to create a testable instance
    init(forTesting: Bool) {
        let stored = UserDefaults.standard.string(forKey: key) ?? "system"
        self.preference = AppearancePreference(rawValue: stored) ?? .system
    }

    /// Cycles to the next preference in the order: system -> light -> dark -> system
    func cyclePreference() {
        preference = preference.next
    }
}
