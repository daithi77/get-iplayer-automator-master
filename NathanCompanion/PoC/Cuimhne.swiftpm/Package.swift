// swift-tools-version: 5.8

// App Playground package. Opens directly in Swift Playgrounds (iPad or Mac)
// or in Xcode (File > Open, choose the .swiftpm folder). No project file needed.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Cuimhne",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Cuimhne",
            targets: ["AppModule"],
            bundleIdentifier: "ie.stpauls.cuimhne.poc",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .pencil),
            accentColor: .presetColor(.red),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
