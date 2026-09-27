import SwiftUI

// MARK: - An Spreagphictiúr · AS: the picture stimulus.
// The five-finger method, a ladder and the examiner's follow-up questions, with the pupil's own answers kept on the device.

struct SpreagHome: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DraftBanner()
                Text("Five fingers, five questions: who, where, what is happening, before and after, and what you think. Then the examiner moves from the picture to your own life.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(store.spreag.enumerated()), id: \.element.id) { i, picture in
                    if !picture.isTeacherLed {
                        NavigationLink {
                            SpreagView(picture: picture)
                        } label: {
                            HStack(spacing: 12) {
                                Text(picture.icon).font(.system(size: 34)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(i + 1). \(picture.title)").font(.headline).foregroundStyle(Theme.ink)
                                    Text("\(picture.titleEn ?? "") · \(picture.allFingers.count) + \(picture.allFollowUps.count) ceist")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(1)).accessibilityHidden(true)
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("An Spreagphictiúr")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SpreagView: View {
    let picture: SpreagPicture

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(picture.titleEn ?? "") · An Spreagphictiúr")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                DraftBanner()
                Panel {
                    Text("An pictiúr · the picture")
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                    VStack(spacing: 6) {
                        Text(picture.icon).font(.system(size: 56)).accessibilityHidden(true)
                        if let scene = picture.scene {
                            Text(scene.ga)
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.center)
                            if let en = scene.en, !en.isEmpty {
                                Text(en)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Theme.rule, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    )
                    Text("Grianghraf le teacht · photo to come: \(picture.photo ?? "")")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
                ForEach(Array(picture.allFingers.enumerated()), id: \.offset) { k, finger in
                    Panel {
                        Text("✋ \(k + 1) · \(finger.finger ?? "")")
                            .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                        Text(finger.q ?? "").font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
                        if let en = finger.qEn, !en.isEmpty {
                            Text(en).font(.subheadline).foregroundStyle(Theme.muted)
                        }
                        if let frames = finger.frames, !frames.isEmpty {
                            FramesBox(frames: frames)
                        }
                        OwnBox(key: "sp:\(picture.id):\(k)")
                        if let model = finger.model {
                            ModelBox(model: model)
                        }
                    }
                }
                if let ladder = picture.ladder, !ladder.isEmpty {
                    Panel {
                        Text("Freagra níos fearr · make it better")
                            .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                        ForEach(Array(ladder.enumerated()), id: \.offset) { _, rung in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(rung.label ?? "")
                                    .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                                Text(Marking.text(rung.ga ?? ""))
                                    .font(.title3)
                                    .foregroundStyle(Theme.ink)
                                    .accessibilityLabel(Marking.plain(rung.ga ?? ""))
                                Text(rung.en ?? "").font(.subheadline).foregroundStyle(Theme.muted)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.ground))
                        }
                    }
                }
                if !picture.allFollowUps.isEmpty {
                    Panel {
                        Text("Ceisteanna leantacha · the examiner's follow-up questions")
                            .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                        ForEach(Array(picture.allFollowUps.enumerated()), id: \.offset) { k, followUp in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(k + 1). \(followUp.ga ?? "")").font(.headline).foregroundStyle(Theme.ink)
                                if let en = followUp.en, !en.isEmpty {
                                    Text(en).font(.subheadline).foregroundStyle(Theme.muted)
                                }
                                OwnBox(key: "spf:\(picture.id):\(k)")
                                if let model = followUp.model {
                                    ModelBox(model: model)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle(picture.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Frámaí: useful chunks for a finger, held back until opened.
struct FramesBox: View {
    let frames: [GaEn]
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            FlowLayout(spacing: 8) {
                ForEach(Array(frames.enumerated()), id: \.offset) { _, frame in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(frame.ga).font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink)
                        if let en = frame.en, !en.isEmpty {
                            Text(en).font(.caption).foregroundStyle(Theme.muted)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Theme.rule))
                    .accessibilityElement(children: .combine)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        } label: {
            Text("Frámaí · useful chunks").font(.headline).foregroundStyle(Theme.ink)
        }
        .tint(Theme.columnInk(0))
    }
}

/// The pupil's own answer, kept on this device with the Comhrá own answers, by key.
struct OwnBox: View {
    @EnvironmentObject private var store: Store
    let key: String
    var placeholder = "Scríobh do fhreagra anseo"
    var minHeight: CGFloat = 90
    /// Irish is written without autocorrect; English keeps it.
    var irish = true

    var body: some View {
        TextEditor(text: Binding(
            get: { store.ownAnswer(key) },
            set: { store.setOwnAnswer(key, $0) }))
            .frame(minHeight: minHeight)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled(irish)
            .padding(6)
            .overlay(alignment: .topLeading) {
                if store.ownAnswer(key).isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
            .accessibilityLabel(placeholder)
    }

    /// Words in a piece of writing: runs of anything but spaces.
    static func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace }).count
    }
}

/// A model answer, held back until opened, with the house marks ([x] red, {x} green) and the English.
struct ModelBox: View {
    let model: GaEn
    var label = "Freagra samplach · model answer"
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Marking.text(model.ga))
                    .font(.body.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityLabel(Marking.plain(model.ga))
                if let en = model.en, !en.isEmpty {
                    Text(en).font(.subheadline).foregroundStyle(Theme.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        } label: {
            Text(label).font(.headline).foregroundStyle(Theme.ink)
        }
        .tint(Theme.columnInk(0))
    }
}
