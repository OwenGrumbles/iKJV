// swift-tools-version: 5.9
// Opens in Swift Playgrounds on iPad AND Xcode on Mac — no .xcodeproj needed.

import PackageDescription

let package = Package(
    name: "iKJV",
    platforms: [
        .iOS("17.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "iKJV",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
