// swift-tools-version: 6.2

// App Playground package. Opens in Xcode (File > Open, choose the .swiftpm folder)
// or in Swift Playgrounds on a Mac or iPad. No project file needed.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Gan Ainm",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "Gan Ainm",
            targets: ["AppModule"],
            bundleIdentifier: "com.feirste.gaeilge",
            displayVersion: "0.3",
            bundleVersion: "5",
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
            ],
            appCategory: .education
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
    ],
    // The code is written for Swift 5 rules; the newer tools version only tells Apple which SDK builds it.
    swiftLanguageModes: [.v5]
)
