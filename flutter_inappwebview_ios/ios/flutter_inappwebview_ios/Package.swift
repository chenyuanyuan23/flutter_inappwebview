// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_inappwebview_ios",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-inappwebview-ios", targets: ["flutter_inappwebview_ios"])
    ],
    dependencies: [
        .package(url: "https://github.com/Weebly/OrderedSet.git", from: "6.0.3")
    ],
    targets: [
        .target(
            name: "flutter_inappwebview_ios_internal",
            path: "Sources/flutter_inappwebview_ios_internal",
            publicHeadersPath: "include"
        ),
        .target(
            name: "flutter_inappwebview_ios",
            dependencies: [
                "flutter_inappwebview_ios_internal",
                .product(name: "OrderedSet", package: "OrderedSet")
            ],
            path: "Sources/flutter_inappwebview_ios",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
