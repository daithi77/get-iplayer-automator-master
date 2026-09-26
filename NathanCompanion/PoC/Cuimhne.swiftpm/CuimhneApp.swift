import SwiftUI
import CoreText

@main
struct CuimhneApp: App {
    @StateObject private var store = Store()

    init() {
        MarkingHand.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

/// Registers the bundled handwriting font at launch. An App Playground has no
/// Info.plist entry for fonts, so the font is loaded through CoreText instead.
enum MarkingHand {
    static let postScriptName = "MarkingHand-Regular"

    static func register() {
        guard let url = Bundle.main.url(forResource: "MarkingHand-Regular", withExtension: "otf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func font(_ size: CGFloat) -> Font {
        .custom(postScriptName, size: size)
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inniu", systemImage: "calendar") }
            IndexView()
                .tabItem { Label("Innéacs", systemImage: "list.bullet.rectangle") }
            GrammarView()
                .tabItem { Label("Gramadach", systemImage: "textformat.abc") }
            SpeakingView()
                .tabItem { Label("Labhairt", systemImage: "mic") }
            SettingsView()
                .tabItem { Label("Socruithe", systemImage: "gearshape") }
        }
        .tint(Theme.pen)
    }
}
