// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SonderScreensaver",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SonderPreview",
            targets: ["SonderPreview"]
        ),
        .library(
            name: "SonderSaverCore",
            targets: ["SonderSaverCore"]
        )
    ],
    targets: [
        .target(
            name: "SonderSaverCore",
            path: "Sources/SonderScreensaver",
            exclude: ["Info.plist"]
        ),
        .executableTarget(
            name: "SonderPreview",
            dependencies: ["SonderSaverCore"],
            path: "Sources/SonderPreview",
            exclude: ["Info.plist"]
        )
    ]
)
