public protocol FieldNameRepresentable {
    var fieldName: String { get }
}

extension String: FieldNameRepresentable {
    public var fieldName: String {
        return self
    }
}

public enum ORMError: Error {
    case missingKey(String)
}

public protocol Application {
    associatedtype DB: Database
    static var database: DB! { get }
}

public protocol Routable {}

public protocol WebServerApplication: Application {
    associatedtype R: Routable
}

public struct Sort: ExpressibleByDictionaryLiteral {
    public enum Order {
        case ascending
        case descending
    }
    
    public var order: [String: Order] = [:]
    
    public init(dictionaryLiteral elements: (FieldNameRepresentable, Order)...) {
        for (key, order) in elements {
            self.order[key.fieldName] = order
        }
    }
}

public protocol DatabaseEntity {
    associatedtype ORMValue
    associatedtype Identifier
    
    static var defaultIdentifierField: String { get }
    
    func getORMIdentifier() -> Identifier?
    func getORMValue(forKey key: String) -> ORMValue?
    mutating func setORMValue(to value: ORMValue?, forKey key: String)
}

public protocol Table {
    associatedtype Query
    associatedtype Entity: DatabaseEntity
    
    func store(_ entity: Entity) throws
    
    func find(matching query: Query?, sorted by: Sort?) throws -> AnyIterator<Entity>
    func findOne(matching query: Query?) throws -> Entity?
    func findOne(byId identifier: Entity.Identifier) throws -> Entity?
    
    func update(matching query: Query?, to entity: Entity) throws
    func update(matchingIdentifier identifier: Entity.Identifier, to entity: Entity) throws
    
    func delete(byId identifier: Entity.Identifier) throws
    
    static func generateIdentifier() -> Entity.Identifier
}

public protocol Database {
    associatedtype T: Table
    
    init(_ connectionString: String) throws
    
    func getTable(named table: String) -> T
}

/// When implemented, it allows conversion to and from a database Entity
public protocol ConcreteSerializable {
    associatedtype T: Table
    
    init(from source: T.Entity) throws
    func serialize() -> T.Entity
    
    mutating func getIdentifier() -> T.Entity.Identifier
    
    static func find(matching query: T.Query?, sorted by: Sort?) throws -> AnyIterator<Self>
    static func findOne(matching query: T.Query?) throws -> Self?
    static func findOne(byId identifier: T.Entity.Identifier) throws -> Self?
}

public protocol Model {
    /// The database identifier
    var id: Any? { get set }
}

public protocol Embeddable {}

public protocol ConcreteModel : Model, ConcreteSerializable {
    /// The table/collection this model resides in
    static var table: T { get }
}

public protocol ConcreteEmbeddable : Embeddable, ConcreteSerializable {
    /// The table/collection this model resides in
    static var table: T { get }
}

extension ConcreteModel {
    public mutating func getIdentifier() -> T.Entity.Identifier {
        if let identifier = self.id as? T.Entity.Identifier {
            return identifier
        } else {
            let identifier = T.generateIdentifier()
            self.id = identifier
            return identifier
        }
    }
    
    public mutating func save() throws {
        if let id = id as? Self.T.Entity.Identifier {
            try Self.table.update(matchingIdentifier: id, to: self.serialize())
        } else {
            id = Self.T.generateIdentifier()
            try Self.table.store(self.serialize())
        }
    }
    
    public func destroy() throws {
        
    }
}
