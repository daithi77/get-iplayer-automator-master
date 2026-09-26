import AVFoundation
import SwiftUI

/// Plays Áine's pre-made clips from the app bundle. One clip at a time; a new clip stops the last.
/// While a sentence plays, `lit` estimates which chunk she is saying, for highlighting.
final class Speaker: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = Speaker()

    @Published private(set) var lit: Int?
    @Published private(set) var playing: String?

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var weights: [Double] = []
    private var onEnd: (() -> Void)?

    override init() {
        super.init()
        // Playback plays through the ring/silent switch, which a classroom needs.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
    }

    func hasClip(_ id: String) -> Bool {
        Bundle.main.url(forResource: id, withExtension: "mp3") != nil
    }

    func play(_ id: String, weights: [Double] = [], onEnd: (() -> Void)? = nil) {
        stop()
        guard let url = Bundle.main.url(forResource: id, withExtension: "mp3"),
              let p = try? AVAudioPlayer(contentsOf: url) else {
            onEnd?()
            return
        }
        try? AVAudioSession.sharedInstance().setActive(true)
        p.delegate = self
        player = p
        playing = id
        self.weights = weights
        self.onEnd = onEnd
        p.play()
        if !weights.isEmpty {
            let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.main.add(t, forMode: .common)
            timer = t
        }
    }

    /// Plays a whole sentence, lighting each chunk in turn. Timing is estimated from chunk length.
    func playSentence(_ s: Sentence, in unit: BuilderUnit, onEnd: (() -> Void)? = nil) {
        let w = s.chunks.map { Double((unit.chunk($0)?.ga.count ?? 1) + 2) }
        play(s.audio, weights: w, onEnd: onEnd)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        playing = nil
        lit = nil
        onEnd = nil
    }

    private func tick() {
        guard let p = player, p.duration > 0 else { return }
        let total = weights.reduce(0, +)
        let x = p.currentTime / p.duration * total
        var acc = 0.0
        for (i, w) in weights.enumerated() {
            acc += w
            if x <= acc {
                if lit != i { lit = i }
                return
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ finished: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            guard finished === self.player else { return }
            let done = self.onEnd
            self.timer?.invalidate()
            self.timer = nil
            self.player = nil
            self.playing = nil
            self.lit = nil
            self.onEnd = nil
            done?()
        }
    }
}
