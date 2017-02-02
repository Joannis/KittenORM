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
    public var firstName: String
    public var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}


var me = User(firstName: "Joannis", lastName: "Orlandos")
try me.save()

let me2 = try User.findOne(byId: me.getIdentifier())

print(me2?.firstName)
print(me2?.lastName)

try me.destroy()

let me3 = try User.findOne(byId: me.getIdentifier())

print(me3?.firstName)
print(me3?.lastName)
