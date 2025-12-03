// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BatComputer",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.7.1"),
    ],
    targets: [
        .executableTarget(
            name: "BatComputer",
            dependencies: [
                "SwiftSoup",
                "Alamofire",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CryptoSwift"
            ],
            path: "Sources",
            sources: ["main.swift", "BatComputerManager.swift", "BatComputerShortcuts.swift", "BatmanResponses.swift", "HomeAutomation.swift", "WeatherService.swift"]
        )
    ]
)