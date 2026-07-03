import Foundation
import SwiftUI
import AppKit

/// Orchestrates the PVR: owns the series list, schedules automatic runs,
/// and records what gets downloaded.
@MainActor
final class AppModel: ObservableObject {
    @Published var series: [PVRSearch] = []
    @Published var recentDownloads: [DownloadRecord] = []
    @Published var isRunning = false
    @Published var lastRun: Date?
    @Published var statusMessage = "Idle"
    @Published var lastError: String?
    @Published private(set) var lastLog = ""

    let settings = Settings()
    private let runner = GetIPlayerRunner()
    private var timer: Timer?

    init() {
        recentDownloads = DownloadRecord.load()
        Task { await refreshSeriesList() }
        rescheduleTimer()
    }

    // MARK: Series links

    func refreshSeriesList() async {
        do {
            let output = try await runner.run(["--pvr-list"], settings: settings)
            series = PVRSearch.parseList(output)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func addSeries(_ searchTerm: String) async {
        let term = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return }
        do {
            _ = try await runner.run(["--type=tv", "--pvr-add=\(pvrName(for: term))", term], settings: settings)
            await refreshSeriesList()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func removeSeries(_ search: PVRSearch) async {
        do {
            _ = try await runner.run(["--pvr-del=\(search.name)"], settings: settings)
            await refreshSeriesList()
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// get_iplayer PVR search names must be word characters only.
    private func pvrName(for term: String) -> String {
        let cleaned = term.unicodeScalars
            .map { CharacterSet.alphanumerics.contains($0) ? Character($0) : "_" }
        return String(cleaned)
    }

    // MARK: PVR runs

    /// Refreshes the programme cache and downloads any new episodes of
    /// linked series. This is the app's whole job.
    func runPVRNow() async {
        guard !isRunning else { return }
        isRunning = true
        lastError = nil
        statusMessage = "Checking for new episodes…"
        defer {
            isRunning = false
            lastRun = Date()
            rescheduleTimer()
        }

        do {
            let output = try await runner.run(
                ["--pvr", "--output=\(settings.outputDirectory)"],
                settings: settings
            )
            lastLog = output

            let recorded = DownloadRecord.parseRecorded(from: output)
            if recorded.isEmpty {
                statusMessage = "No new episodes."
            } else {
                let records = recorded.map { DownloadRecord(path: $0) }
                recentDownloads = records + recentDownloads
                DownloadRecord.save(recentDownloads)
                statusMessage = "Downloaded \(recorded.count) new episode\(recorded.count == 1 ? "" : "s")."
                Notifier.notify(
                    title: "MediaHub",
                    body: records.map(\.displayName).joined(separator: "\n")
                )
            }
        } catch {
            lastError = error.localizedDescription
            statusMessage = "Last run failed."
        }
    }

    // MARK: Scheduling

    func rescheduleTimer() {
        timer?.invalidate()
        let interval = TimeInterval(settings.checkIntervalHours) * 3600
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.runPVRNow()
            }
        }
    }

    var nextRun: Date? {
        timer?.fireDate
    }

    // MARK: Log viewing

    /// Writes the last run's log to a temp file and opens it.
    func openLastLog() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("MediaHub-last-run.log")
        try? lastLog.write(to: url, atomically: true, encoding: .utf8)
        NSWorkspace.shared.open(url)
    }
}
