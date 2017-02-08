/// Anything that represents a FieldName
///
/// Either a String or a Type-Safe querylanguage object
public protocol FieldNameRepresentable {
    var fieldName: String { get }
}

/// Allows a String to represent a field name
extension String: FieldNameRepresentable {
    public var fieldName: String {
        return self
    }
}

/// Generic errors you can throw in the ORM when (de)serializing
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

public protocol Serializable {}

public protocol SerializableObject {
    associatedtype SupportedValue = Serializable.Type
    
    init(dictionary: [String: SupportedValue])
    
    func getValue(forKey key: String) -> SupportedValue?
    mutating func setValue(to newValue: SupportedValue?, forKey key: String)
    
    func getKeys() -> [String]
    func getValues() -> [SupportedValue]
    func getKeyValuePairs() -> [String: SupportedValue]
}

public protocol DatabaseEntity: SerializableObject {
    associatedtype Identifier
    
    static var defaultIdentifierField: String { get }
    
    func getIdentifier() -> Identifier?
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
    func delete(_ entity: Entity) throws
    
    static func generateIdentifier() -> Entity.Identifier
}

extension Table {
    public func delete(_ entity: Entity) throws {
        guard let id = entity.getIdentifier() else {
            throw ORMError.missingKey(Entity.defaultIdentifierField)
        }
        
        return try self.delete(byId: id)
    }
}

public protocol Database {
    associatedtype T: Table
    
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

extension ConcreteSerializable {
    public func convert<S: SerializableObject>(to type: S.Type) -> (converted: S, remainder: Self.T.Entity) {
        var s = S(dictionary: [:])
        
        var remainder = T.Entity(dictionary: [:])
        
        for (key, value) in self.serialize().getKeyValuePairs() {
            if let value = value as? S.SupportedValue {
                s.setValue(to: value, forKey: key)
//            } else if let value = T.Entity.self.convert(value, to: S.self) {
//                s.setValue(to: value, forKey: key)
            } else {
                remainder.setValue(to: value, forKey: key)
            }
        }
        
        return (s, remainder)
    }
}

public protocol Model {
    /// The database identifier
    var id: Any? { get set }
}

public protocol SchemalessModel : ConcreteModel {
    var extraFields: T.Entity? { get }
}

public protocol Embeddable {}

public protocol ConcreteModel : Model, ConcreteSerializable {
    /// The table/collection this model resides in
    static var table: T { get }
}

public protocol ConcreteEmbeddable : Embeddable, ConcreteSerializable {}

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
        if let id = id as? Self.T.Entity.Identifier {
            try Self.table.delete(byId: id)
        }
    }
}
