// swift-tools-version: 5.9
// Swift Playgrounds on iPad: open the iKJV.swiftpm folder.

import PackageDescription

let package = Package(
    name: "iKJV",
    platforms: [
        .iOS("17.0")
    ],
    targets: [
        .target(
            name: "iKJV",
            path: ".",
            exclude: [
                "Info.plist",
                "Package.swift"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
