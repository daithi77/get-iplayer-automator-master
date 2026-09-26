// swift-tools-version: 5.9

// App Playground package. Opens in Xcode (File > Open, choose the .swiftpm folder)
// or in Swift Playgrounds on a Mac or iPad. No project file needed.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Gan Ainm",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Gan Ainm",
            targets: ["AppModule"],
            bundleIdentifier: "com.feirste.gaeilge",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.blue),
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
