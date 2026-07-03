import Foundation

/// User-configurable settings, persisted to UserDefaults.
final class Settings: ObservableObject {
    private static let defaults = UserDefaults.standard

    /// Path to the get_iplayer executable or .pl script.
    /// Defaults to the Homebrew install location if present.
    @Published var getIPlayerPath: String {
        didSet { Self.defaults.set(getIPlayerPath, forKey: "getIPlayerPath") }
    }

    /// Directory new recordings are written to.
    @Published var outputDirectory: String {
        didSet { Self.defaults.set(outputDirectory, forKey: "outputDirectory") }
    }

    /// Hours between automatic PVR runs.
    @Published var checkIntervalHours: Int {
        didSet { Self.defaults.set(checkIntervalHours, forKey: "checkIntervalHours") }
    }

    /// get_iplayer keeps its PVR searches and download history here, so
    /// MediaHub's series links are independent of any other install.
    let profileDirectory: String

    init() {
        let candidates = [
            "/opt/homebrew/bin/get_iplayer",
            "/usr/local/bin/get_iplayer",
        ]
        let detected = candidates.first { FileManager.default.isExecutableFile(atPath: $0) }

        getIPlayerPath = Self.defaults.string(forKey: "getIPlayerPath") ?? detected ?? ""
        outputDirectory = Self.defaults.string(forKey: "outputDirectory")
            ?? (NSSearchPathForDirectoriesInDomains(.moviesDirectory, .userDomainMask, true).first ?? NSHomeDirectory())
        let interval = Self.defaults.integer(forKey: "checkIntervalHours")
        checkIntervalHours = interval > 0 ? interval : 6

        let appSupport = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        profileDirectory = (appSupport as NSString).appendingPathComponent("MediaHub")
        try? FileManager.default.createDirectory(atPath: profileDirectory, withIntermediateDirectories: true)
    }
}
