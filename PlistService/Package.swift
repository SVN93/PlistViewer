// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlistService",
	platforms: [
		.macOS(.v10_15), .iOS(.v13)
	],
    products: [
        .library(name: "PlistService", targets: ["PlistService"])
    ],
	dependencies: [
	],
    targets: [
        .target(name: "PlistService", dependencies: []),
        .testTarget(name: "PlistServiceTests", dependencies: ["PlistService"])
    ]
)
