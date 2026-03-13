// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "iKJV",
    platforms: [
        .iOS("17.0")
    ],
    targets: [
        .executableTarget(
            name: "iKJV",
            path: ".",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
