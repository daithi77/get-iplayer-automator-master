import Foundation

/// A completed recording, kept so the menu can show what arrived overnight.
struct DownloadRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let path: String
    let date: Date

    var displayName: String {
        ((path as NSString).lastPathComponent as NSString).deletingPathExtension
    }

    init(path: String, date: Date = Date()) {
        self.id = UUID()
        self.path = path
        self.date = date
    }

    // MARK: Persistence

    private static var storeURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("MediaHub")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("downloads.json")
    }

    static func load() -> [DownloadRecord] {
        guard let data = try? Data(contentsOf: storeURL),
              let records = try? JSONDecoder().decode([DownloadRecord].self, from: data) else {
            return []
        }
        return records
    }

    static func save(_ records: [DownloadRecord]) {
        // Cap the history so the file and menu stay small.
        let trimmed = Array(records.prefix(50))
        if let data = try? JSONEncoder().encode(trimmed) {
            try? data.write(to: storeURL)
        }
    }

    /// Pulls recorded file paths out of a `--pvr` run's log. get_iplayer
    /// reports each success as "INFO: Recorded <path>".
    static func parseRecorded(from output: String) -> [String] {
        var paths: [String] = []
        for line in output.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let range = trimmed.range(of: "INFO: Recorded ") {
                paths.append(String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces))
            }
        }
        return paths
    }
}
