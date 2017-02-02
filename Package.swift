import PackageDescription

let package = Package(
    name: "KittenORM",
    targets: [
        Target(name: "KittenORM"),
        Target(name: "MongoKittenORM", dependencies: ["KittenORM"]),
        Target(name: "KittenORMExample", dependencies: ["MongoKittenORM"])
    ],
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", "3.1.0-beta3")
    ]
)
