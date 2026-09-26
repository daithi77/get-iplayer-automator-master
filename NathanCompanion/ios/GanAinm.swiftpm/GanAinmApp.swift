import SwiftUI

@main
struct GanAinmApp: App {
    @StateObject private var store = Store()

    init() {
        Pen.register()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
        }
    }
}
