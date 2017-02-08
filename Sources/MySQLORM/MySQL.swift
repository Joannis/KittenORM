//@_exported import KittenORM
//@_exported import SwiftKuery
//
//extension MySQL.Database : KittenORM.Database {
//    public typealias T = MySQLTable
//    
//    public func getTable(named table: String) -> MySQLTable {
//        return MySQLTable(named: table, inDatabase: self)
//    }
//}
//
//public struct MySQLTable: KittenORM.Table {
//    public typealias ORMValue = MySQL.Value
//    
//    let database: MySQL.Database
//    let name: String
//    
//    init(named name: String, inDatabase db: MySQL.Database) {
//        self.name = name
//        self.database = db
//    }
//}
