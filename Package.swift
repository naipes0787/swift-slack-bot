// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "slackBotTest",
    products: [
        .executable(name: "slackBotTest", targets: ["slackBotTest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pvzig/SlackKit.git", .upToNextMinor(from: "4.3.0")),
        .package(url: "https://github.com/IBM-Swift/Configuration.git", .upToNextMinor(from: "3.0.4"))
    ],
    targets: [
        .target(name: "slackBotTest",
                dependencies: ["SlackKit", "Configuration"])
    ]
)
