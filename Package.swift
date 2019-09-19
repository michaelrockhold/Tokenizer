// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tokenizer",
    products: [
        .library(
            name: "Tokenizer",
            targets: ["Tokenizer"]),
    ],
    dependencies: [], // This is not dependent on anything outside of Foundation.
    
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: []),
        .testTarget(
            name: "TokenizerTests",
            dependencies: ["Tokenizer"]),
    ]
)
