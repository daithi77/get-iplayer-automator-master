import SwiftUI
import AVFoundation

struct SpeakingView: View {
    @EnvironmentObject private var store: Store

    struct TopicEntry: Identifiable {
        let topic: String
        let context: String
        let questions: [Question]
        var id: String { topic }
    }

    private var topics: [TopicEntry] {
        var order: [String] = []
        var byTopic: [String: [Question]] = [:]
        var ctx: [String: String] = [:]
        for q in store.questions {
            if byTopic[q.topic] == nil { order.append(q.topic) }
            byTopic[q.topic, default: []].append(q)
            ctx[q.topic] = q.context
        }
        return order.map { TopicEntry(topic: $0, context: ctx[$0] ?? "", questions: byTopic[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.paper.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                               unit: "Aonad 2 · Labhairt", right: "Ceisteanna")
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Rubric(ga: "Roghnaigh ábhar, ansin ceist.", en: "Choose a topic, then a question.")
                        .padding(.horizontal, 20)
                        .padding(.top, 14)

                    List {
                        ForEach(topics) { t in
                            NavigationLink(value: t.topic) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t.topic).font(.system(size: 17, weight: .semibold)).foregroundColor(Theme.ink)
                                        Text(t.context).font(.footnote).foregroundColor(Theme.grey)
                                    }
                                    Spacer()
                                    let done = t.questions.filter { !(store.spokenAnswers[$0.id] ?? "").isEmpty }.count
                                    Text("\(done)/\(t.questions.count)").font(MarkingHand.font(20)).foregroundColor(Theme.grey)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Theme.paper)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top, 6)
                }
            }
            .navigationDestination(for: String.self) { topic in
                TopicQuestionsView(topic: topic, questions: store.questions.filter { $0.topic == topic })
            }
            .navigationDestination(for: Question.self) { q in
                QuestionView(question: q)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct TopicQuestionsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let topic: String
    let questions: [Question]

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.body.weight(.semibold)).frame(width: 44, height: 44)
                    }
                    .foregroundColor(Theme.ink)
                    Text(topic).font(.system(size: 18, weight: .bold)).foregroundColor(Theme.ink).lineLimit(2)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                List(questions) { q in
                    NavigationLink(value: q) {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(q.ga).font(.system(size: 16)).foregroundColor(Theme.ink)
                            Spacer()
                            if !(store.spokenAnswers[q.id] ?? "").isEmpty {
                                Text("✓").font(MarkingHand.font(18)).foregroundColor(Theme.pen)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Theme.paper)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct QuestionView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = Recorder()
    let question: Question
    @State private var text = ""
    @FocusState private var editing: Bool

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.body.weight(.semibold)).frame(width: 44, height: 44)
                    }
                    .foregroundColor(Theme.ink)
                    Text(question.topic).font(.system(size: 16, weight: .semibold)).foregroundColor(Theme.grey).lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 8)

                Rubric(ga: "Freagair an cheist i nGaeilge. Labhair ar feadh 30 soicind ar a laghad.",
                       en: "Answer in Irish. Speak for at least 30 seconds.")
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Scrúdaitheoir").tracking(0.5).font(.caption).textCase(.uppercase).foregroundColor(Theme.grey)
                    Text(question.ga).font(.system(size: 21, weight: .bold)).foregroundColor(Theme.ink)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1.5))
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ZStack(alignment: .topLeading) {
                    RuledPaper()
                    TextEditor(text: $text)
                        .font(.system(size: 19))
                        .foregroundColor(Theme.biro)
                        .lineSpacing(Theme.lineHeight - 23)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($editing)
                        .padding(.leading, Theme.marginX + 8)
                        .padding(.trailing, 16)
                        .padding(.top, 2)
                    if text.isEmpty {
                        Text("Scríobh do fhreagra féin anseo…")
                            .font(.system(size: 19)).foregroundColor(Theme.grey.opacity(0.7))
                            .padding(.leading, Theme.marginX + 13).padding(.top, 10)
                            .allowsHitTesting(false)
                    }
                    if !text.isEmpty {
                        PenMark(text: "✓", size: 26, tilt: 0).frame(width: Theme.marginX).padding(.top, 4)
                    }
                }
                .padding(.top, 12)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recorder.timeText).font(.system(size: 22, weight: .bold)).foregroundColor(Theme.ink)
                        Text(recorder.status).font(.footnote).foregroundColor(Theme.grey)
                    }
                    Spacer()
                    Button {
                        editing = false
                        recorder.toggleRecording(id: question.id)
                    } label: {
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Theme.pen)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Theme.ink, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Taifead")
                    Spacer()
                    Button {
                        recorder.togglePlayback(id: question.id)
                    } label: {
                        Image(systemName: recorder.isPlaying ? "stop.circle" : "play.circle")
                            .font(.system(size: 34))
                            .foregroundColor(recorder.hasRecording(id: question.id) ? Theme.ink : Theme.grey.opacity(0.4))
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.plain)
                    .disabled(!recorder.hasRecording(id: question.id) || recorder.isRecording)
                    .accessibilityLabel("Éist")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.paper)
                .overlay(Rectangle().frame(height: 1.5).foregroundColor(Theme.ink), alignment: .top)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { c in
                    Button(c) { text += c }.font(.system(size: 22)).frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                Button("Déanta") { editing = false }.fontWeight(.bold)
            }
        }
        .onAppear { text = store.spokenAnswers[question.id] ?? "" }
        .onChange(of: text) { new in store.spokenAnswers[question.id] = new }
        .onDisappear { recorder.stopAll() }
    }
}

/// Records one answer per question to the app's Documents folder and plays it back.
final class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var seconds: Int = 0
    @Published var status: String = "coinnigh · tap to record"

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var timer: Timer?

    var timeText: String { String(format: "%d:%02d", seconds / 60, seconds % 60) }

    private func url(for id: String) -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("answer-\(id).m4a")
    }

    func hasRecording(id: String) -> Bool { FileManager.default.fileExists(atPath: url(for: id).path) }

    func toggleRecording(id: String) {
        if isRecording { stopRecording() } else { startRecording(id: id) }
    }

    private func startRecording(id: String) {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                guard granted else { self.status = "níl cead micreafóin · no microphone permission"; return }
                do {
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)
                    let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                    ]
                    let r = try AVAudioRecorder(url: self.url(for: id), settings: settings)
                    r.delegate = self
                    r.record()
                    self.recorder = r
                    self.isRecording = true
                    self.seconds = 0
                    self.status = "ag taifeadadh · recording"
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                        self?.seconds += 1
                    }
                } catch {
                    self.status = "theip ar an taifeadadh · recording failed"
                }
            }
        }
    }

    private func stopRecording() {
        recorder?.stop()
        recorder = nil
        timer?.invalidate(); timer = nil
        isRecording = false
        status = "taifeadta \(timeText) · recorded"
    }

    func togglePlayback(id: String) {
        if isPlaying {
            player?.stop(); isPlaying = false; status = "stoptha · stopped"
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            let p = try AVAudioPlayer(contentsOf: url(for: id))
            p.delegate = self
            p.play()
            player = p
            isPlaying = true
            status = "ag seinm · playing"
        } catch {
            status = "níl taifeadadh ann · no recording"
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        status = "éist arís · listen again"
    }

    func stopAll() {
        if isRecording { stopRecording() }
        player?.stop(); isPlaying = false
    }
}
