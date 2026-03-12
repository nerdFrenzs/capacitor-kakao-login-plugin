// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorKakaoLoginPlugin",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorKakaoLoginPlugin",
            targets: ["CapacitorKakaoLoginPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .branch("master"))
    ],
    targets: [
        .target(
            name: "CapacitorKakaoLoginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "KakaoSDKCommon", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKAuth", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKUser", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKTalk", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKShare", package: "kakao-ios-sdk"),
                .product(name: "KakaoSDKTemplate", package: "kakao-ios-sdk")
            ],
            path: "ios/Plugin"
        )
    ]
)
