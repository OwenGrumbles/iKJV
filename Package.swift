// swift-tools-version: 5.9
// Xcode on Mac: open iKJV.xcodeproj  OR  swift build from repo root.
// iPad Swift Playgrounds: open the iKJV.swiftpm folder.

import PackageDescription

let package = Package(
    name: "iKJV",
    platforms: [
        .iOS("17.0")
    ],
    targets: [
        .target(
            name: "iKJV",
            path: "iKJV.swiftpm/Sources",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
