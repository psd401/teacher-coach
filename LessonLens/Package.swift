// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LessonLens",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LessonLens", targets: ["LessonLens"])
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: "LessonLens",
            dependencies: [
                "WhisperKit",
            ],
            path: "LessonLens",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LessonLensTests",
            dependencies: ["LessonLens"],
            path: "LessonLensTests"
        )
    ]
)
