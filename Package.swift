// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "BatComputer",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/PureSwift/BluetoothLinux.git", from: "5.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.7.1"),
    ],
    targets: [
        .executableTarget(
            name: "BatComputer",
            dependencies: [
                "SwiftSoup",
                "Alamofire",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "BluetoothLinux",
                "CryptoSwift"
            ],
            path: "Sources"
        )
    ]
)