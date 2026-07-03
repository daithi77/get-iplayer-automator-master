import Foundation

struct GetIPlayerError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// Executes get_iplayer as a subprocess and returns its combined output.
struct GetIPlayerRunner {

    /// Arguments prepended to every invocation.
    private func baseArguments(settings: Settings) -> [String] {
        [
            "--nocopyright",
            "--profile-dir=\(settings.profileDirectory)",
        ]
    }

    func run(_ arguments: [String], settings: Settings) async throws -> String {
        let path = settings.getIPlayerPath
        guard !path.isEmpty else {
            throw GetIPlayerError(message: "get_iplayer path is not set. Install it (brew install get_iplayer) or point MediaHub at it in Settings.")
        }
        guard FileManager.default.fileExists(atPath: path) else {
            throw GetIPlayerError(message: "get_iplayer not found at \(path).")
        }

        let process = Process()
        // A .pl script is run through perl (as Get iPlayer Automator does);
        // a Homebrew-installed script is executable directly.
        if path.hasSuffix(".pl") {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
            process.arguments = [path] + baseArguments(settings: settings) + arguments
        } else {
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = baseArguments(settings: settings) + arguments
        }

        var environment = ProcessInfo.processInfo.environment
        environment["HOME"] = NSHomeDirectory()
        environment["PERL_UNICODE"] = "AS"
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        return try await withCheckedThrowingContinuation { continuation in
            do {
                var output = Data()
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    output.append(handle.availableData)
                }
                process.terminationHandler = { _ in
                    pipe.fileHandleForReading.readabilityHandler = nil
                    if let remaining = try? pipe.fileHandleForReading.readToEnd() {
                        output.append(remaining)
                    }
                    let text = String(data: output, encoding: .utf8) ?? ""
                    continuation.resume(returning: text)
                }
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
