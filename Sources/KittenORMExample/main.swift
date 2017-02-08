import KittenORM
import MongoKittenORM
import CheetahKittenORM

public class KittenORMExample: Application {
    public typealias DB = MongoDB
    
    public static let database: MongoDB! = try! MongoDB(mongoURL: "mongodb://localhost:27017/ormtest")
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

print(me2?.firstName as Any)
print(me2?.lastName as Any)

try me.destroy()

let me3 = try User.findOne(byId: me.getIdentifier())

print(me3?.firstName as Any)
print(me3?.lastName as Any)

print(me2?.convert(to: JSONObject.self))
