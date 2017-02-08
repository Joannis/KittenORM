import PackageDescription

let package = Package(
    name: "KittenORM",
    targets: [
        Target(name: "KittenORM"),
        Target(name: "MongoKittenORM", dependencies: ["KittenORM"]),
        Target(name: "CheetahKittenORM", dependencies: ["KittenORM"]),
//        Target(name: "MySQLORM", dependencies: ["KittenORM"]),
//        Target(name: "KueryORM", dependencies: ["KittenORM"]),
//        Target(name: "CouchORM", dependencies: ["KittenORM"]),
        Target(name: "KittenORMExample", dependencies: ["MongoKittenORM", "CheetahKittenORM"])
    ],
    dependencies: [
    .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3, minor: 1),
    .Package(url: "https://github.com/OpenKitten/Cheetah.git", majorVersion: 0, minor: 1),
    //.Package(url: "https://github.com/vapor/mysql.git", majorVersion: 1, minor: 1),
    //.Package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", majorVersion: 0, minor: 5),
    //.Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", majorVersion: 1, minor: 6)
    ]
)
