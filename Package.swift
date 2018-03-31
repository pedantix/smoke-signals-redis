// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "smoke-signals-redis",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),

        // A Key Value Store and Message Broker
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["Redis", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

