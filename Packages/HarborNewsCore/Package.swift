// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HarborNewsCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "HarborNewsCore", targets: ["HarborNewsCore"])
    ],
    targets: [
        .target(name: "HarborNewsCore"),
        .testTarget(name: "HarborNewsCoreTests", dependencies: ["HarborNewsCore"])
    ]
)
