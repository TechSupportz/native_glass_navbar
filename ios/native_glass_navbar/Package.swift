// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_glass_navbar",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "native-glass-navbar", targets: ["native_glass_navbar"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "native_glass_navbar",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
