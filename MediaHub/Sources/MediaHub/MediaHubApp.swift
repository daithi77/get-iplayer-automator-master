import SwiftUI
import AppKit

@main
struct MediaHubApp: App {
    @StateObject private var model = AppModel()

    init() {
        // Run as a menu-bar-only app: no Dock icon, no main window.
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuView()
                .environmentObject(model)
        } label: {
            Image(systemName: model.isRunning ? "arrow.down.circle.fill" : "tv")
        }
        .menuBarExtraStyle(.window)
    }
}
