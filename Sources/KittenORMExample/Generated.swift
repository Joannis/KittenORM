import KittenORM
import MongoKittenORM

extension User : ConcreteModel {
    public func serialize() -> Document {
        return [
            "_id": id as? ValueConvertible,
            "firstName": self.firstName,
            "lastName": self.lastName
        ]
    }
    
    typealias T = KittenORMExample.DB.T
    
    static var table = KittenORMExample.database.getTable(named: "users")
    
    convenience init(from source: Document) throws {
        guard let firstName = source["firstName"] as String? else {
            throw ORMError.missingKey("firstName")
        }
        
        guard let lastName = source["lastName"] as String? else {
            throw ORMError.missingKey("lastName")
        }
        
        self.init(firstName: firstName, lastName: lastName)
        
        self.id = source.getIdentifier()
    }
}
