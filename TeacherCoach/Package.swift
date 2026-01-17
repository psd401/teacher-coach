// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TeacherCoach",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TeacherCoach", targets: ["TeacherCoach"])
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit", from: "0.9.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0")
    ],
    targets: [
        .executableTarget(
            name: "TeacherCoach",
            dependencies: [
                "WhisperKit",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            path: "TeacherCoach",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TeacherCoachTests",
            dependencies: ["TeacherCoach"],
            path: "TeacherCoachTests"
        )
    ]
)
