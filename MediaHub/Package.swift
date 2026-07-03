// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MediaHub",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MediaHub",
            path: "Sources/MediaHub"
        )
    ]
)
