// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "swiftFanClub",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git",
                 .upToNextMinor(from: "3.3.0")),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git",
                 .upToNextMinor(from: "3.0.0")),
        // Fluent driver for SQLite
        .package(url: "https://github.com/vapor/fluent-sqlite.git",
                 .upToNextMinor(from: "3.0.0")),
        // 🔑 Hashing (BCrypt, SHA2, HMAC), encryption (AES), public-key (RSA), and random data generation.
        .package(url: "https://github.com/vapor/crypto.git",
                 .upToNextMinor(from: "3.3.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite",
                                            "Crypto", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
