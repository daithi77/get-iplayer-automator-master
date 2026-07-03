import SwiftUI
import AppKit

struct MenuView: View {
    @EnvironmentObject private var model: AppModel
    @State private var newSeriesName = ""
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            downloadsSection
            Divider()
            seriesSection
            Divider()
            footer
        }
        .padding(12)
        .frame(width: 320)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("MediaHub").font(.headline)
                Spacer()
                if model.isRunning {
                    ProgressView().controlSize(.small)
                }
            }
            Text(model.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(3)
            }
            HStack {
                Button("Check & Download Now") {
                    Task { await model.runPVRNow() }
                }
                .disabled(model.isRunning)
                if !model.lastLog.isEmpty {
                    Button("View Log") { model.openLastLog() }
                }
            }
            if let lastRun = model.lastRun {
                Text("Last run \(lastRun.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if let nextRun = model.nextRun {
                Text("Next automatic check \(nextRun.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: Recent downloads

    private var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Downloads")
                .font(.subheadline.bold())
            if model.recentDownloads.isEmpty {
                Text("Nothing yet — new episodes will appear here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.recentDownloads.prefix(8)) { record in
                    HStack {
                        Text(record.displayName)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            NSWorkspace.shared.activateFileViewerSelecting(
                                [URL(fileURLWithPath: record.path)]
                            )
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .buttonStyle(.borderless)
                        .help("Show in Finder")
                    }
                }
            }
        }
    }

    // MARK: Series links

    private var seriesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Series Links")
                .font(.subheadline.bold())
            ForEach(model.series) { search in
                HStack {
                    Text(search.searchTerm)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        Task { await model.removeSeries(search) }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .help("Stop watching this series")
                }
            }
            HStack {
                TextField("Add series (e.g. Doctor Who)", text: $newSeriesName)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .onSubmit(addSeries)
                Button("Add", action: addSeries)
                    .disabled(newSeriesName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addSeries() {
        let name = newSeriesName
        newSeriesName = ""
        Task { await model.addSeries(name) }
    }

    // MARK: Footer

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureGroup("Settings", isExpanded: $showSettings) {
                SettingsPane(settings: model.settings) {
                    model.rescheduleTimer()
                }
            }
            .font(.subheadline)
            HStack {
                Spacer()
                Button("Quit MediaHub") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
            }
        }
    }

}

private struct SettingsPane: View {
    @ObservedObject var settings: Settings
    let onIntervalChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            LabeledContent("get_iplayer") {
                TextField("Path", text: $settings.getIPlayerPath)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledContent("Save to") {
                TextField("Folder", text: $settings.outputDirectory)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledContent("Check every") {
                Picker("", selection: $settings.checkIntervalHours) {
                    ForEach([1, 3, 6, 12, 24], id: \.self) { hours in
                        Text("\(hours)h").tag(hours)
                    }
                }
                .labelsHidden()
                .onChange(of: settings.checkIntervalHours) { _ in
                    onIntervalChange()
                }
            }
        }
        .font(.caption)
    }
}
