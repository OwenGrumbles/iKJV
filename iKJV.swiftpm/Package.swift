// swift-tools-version: 5.9
// iPad: open the iKJV.swiftpm folder in Swift Playgrounds.
// Mac: open iKJV.xcodeproj in Xcode.

import PackageDescription

let package = Package(
    name: "iKJV",
    platforms: [
        .iOS("17.0")
    ],
    targets: [
        .target(
            name: "iKJV",
            path: "Sources",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
