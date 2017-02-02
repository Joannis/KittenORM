import KittenORM
import MongoKittenORM
import MongoKitten

public class KittenORMExample: Application {
    public typealias DB = MongoDB
    
    public static let database: MongoDB! = try! MongoDB("mongodb://localhost:27017/ormtest")
}

final class User : Model {
    /// The database identifier
    public var id: Any?
    
    init() {}
}



// TODO: Generate this

extension User : ConcreteModel {
    public func serialize() -> Document {
        return [
            "_id": id as? ValueConvertible
        ]
    }

    typealias T = KittenORMExample.DB.T
    
    static var table = KittenORMExample.database.getTable(named: "users")
    
    convenience init(from source: Document) throws {
        self.init()
        
        self.id = source.getORMIdentifier()
    }
}
