import SwiftUI

/// Shown on first launch, and from the ⓘ button on the home screen.
/// DRAFT WORDING: awaiting Dáithí's sign-off, Irish and English.
struct IntroView: View {
    let onDone: () -> Void
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                welcome.tag(0)
                howItWorks.tag(1)
                why.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    onDone()
                }
            } label: {
                Text(page < 2 ? "Ar aghaidh" : "Tosaigh")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.ink)
            .padding()
        }
        .background(Theme.ground)
    }

    private func pageBody<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                content()
            }
            .padding(24)
            .padding(.bottom, 40)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }

    private var welcome: some View {
        pageBody {
            Text("💬").font(.system(size: 64)).accessibilityHidden(true)
            Text("Gan Ainm")
                .font(.largeTitle.weight(.bold))
            Text("Gaeilge le rá os ard.")
                .font(Pen.font(34))
                .foregroundStyle(Theme.pen)
                .rotationEffect(.degrees(-2))
            Text("Irish you can say out loud.")
                .font(.title3)
            Text("Gan Ainm uses the same sentence builders you work with in class. Every chunk and every sentence is spoken by Áine, a native Ulster voice, so you hear it before you say it.")
                .foregroundStyle(Theme.muted)
        }
    }

    private var howItWorks: some View {
        pageBody {
            Text("Mar a oibríonn sé")
                .font(.largeTitle.weight(.bold))
            Text("How it works: about six minutes, four steps.")
                .foregroundStyle(Theme.muted)
            step("👂", "Éist", "Listen", "Hear every chunk and whole sentences before you try them.")
            step("👀", "Aithin", "Recognise", "Pick out the chunks you hear, and what a sentence means.")
            step("🧱", "Tóg", "Build", "Put sentences together from chunks, not single words.")
            step("🧠", "Ó chuimhne", "From memory", "Write them with no help, then answer a real question about yourself.")
            Text("Anything you find hard comes back sooner. Anything you know well comes back later.")
                .foregroundStyle(Theme.muted)
        }
    }

    private var why: some View {
        pageBody {
            Text("Cad chuige?")
                .font(.largeTitle.weight(.bold))
            Text("Why it works this way")
                .foregroundStyle(Theme.muted)
            point("Language comes in chunks.", "Fluent speakers use ready-made phrases. Learning them whole is faster than building every sentence word by word.")
            point("Listening comes first.", "Lots of listening and reading give you the patterns. Speaking grows out of them.")
            point("Memory is the engine.", "Recalling a sentence from memory, again and again over days, is what makes it stick.")
            point("Little and often.", "A few minutes a night beats an hour once a week.")
            Text("Gan Ainm follows the general direction of the new Northern Ireland curriculum for languages: pupils using the language to talk about themselves and their world, with growing confidence in speaking.")
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.fill(0)))
                .foregroundStyle(Theme.columnInk(0))
            Text("Voice: Áine, ABAIR, Trinity College Dublin. Progress stays on this device.")
                .font(.footnote)
                .foregroundStyle(Theme.muted)
        }
    }

    private func step(_ emoji: String, _ ga: String, _ en: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(emoji).font(.system(size: 34)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(ga) · \(en)").font(.headline)
                Text(text).foregroundStyle(Theme.muted)
            }
        }
    }

    private func point(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(text).foregroundStyle(Theme.muted)
        }
    }
}
