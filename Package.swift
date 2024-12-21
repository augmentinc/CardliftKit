// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CardliftKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "CardliftKit", targets: ["CardliftKit"]),
    ],
    targets: [
        .target(
            name: "CardliftKit",
            path: "Sources"
        ),
    ]
)
