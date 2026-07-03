import Foundation

/// One series link, backed by a get_iplayer PVR search.
struct PVRSearch: Identifiable, Hashable {
    let name: String        // get_iplayer's internal search name
    let searchTerm: String  // the human-entered series name
    let type: String        // tv, radio, ...

    var id: String { name }

    /// Parses `get_iplayer --pvr-list` output, which looks like:
    ///
    ///     pvrsearch = doctor_who
    ///         search0 = doctor who
    ///         type = tv
    ///
    static func parseList(_ output: String) -> [PVRSearch] {
        var results: [PVRSearch] = []
        var name: String?
        var fields: [String: String] = [:]

        func flush() {
            if let name {
                results.append(PVRSearch(
                    name: name,
                    searchTerm: fields["search0"] ?? fields["search"] ?? name,
                    type: fields["type"] ?? "tv"
                ))
            }
            name = nil
            fields = [:]
        }

        for rawLine in output.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard let separator = line.range(of: " = ") else { continue }
            let key = String(line[..<separator.lowerBound])
            let value = String(line[separator.upperBound...])
            if key == "pvrsearch" {
                flush()
                name = value
            } else if name != nil {
                fields[key] = value
            }
        }
        flush()
        return results
    }
}
