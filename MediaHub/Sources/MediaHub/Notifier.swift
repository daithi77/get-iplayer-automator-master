import Foundation

/// Posts user notifications via osascript. UNUserNotificationCenter needs a
/// signed app bundle, which a bare `swift run` executable doesn't have — this
/// keeps the prototype notification-capable until MediaHub ships as a .app.
enum Notifier {
    static func notify(title: String, body: String) {
        let escape = { (s: String) in s.replacingOccurrences(of: "\"", with: "\\\"") }
        let script = "display notification \"\(escape(body))\" with title \"\(escape(title))\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        try? process.run()
    }
}
