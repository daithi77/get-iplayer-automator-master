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
    @EnvironmentObject private var store: Store
    @State private var phase: Phase = .home

    enum Phase {
        case home
        case session(Session)
        case results(SessionResult)
    }

    var body: some View {
        NavigationStack {
          ZStack {
            Theme.paper.ignoresSafeArea()
            switch phase {
            case .home:
                HomeView(start: {
                    phase = .session(store.makeSession())
                })
            case .session(let session):
                SessionView(session: session, finish: { result in
                    store.record(result)
                    phase = .results(result)
                })
            case .results(let result):
                ResultsView(result: result, again: {
                    phase = .session(store.makeSession())
                }, home: {
                    phase = .home
                })
            }
          }
          .toolbar(.hidden, for: .navigationBar)
        }
    }
}
