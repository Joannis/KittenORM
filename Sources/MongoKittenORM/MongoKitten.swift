@_exported import KittenORM
@_exported import BSON
import MongoKitten

public typealias MongoDB = MongoKitten.Database

extension Document: DatabaseEntity {
    public typealias Identifier = ValueConvertible
    public typealias ORMValue = ValueConvertible
    
    public static let defaultIdentifierField: String = "_id"
    
    public func getORMIdentifier() -> ValueConvertible? {
        return self[raw: "_id"]
    }
    
    public func getORMValue(forKey key: String) -> ValueConvertible? {
        return self[raw: key]
    }
    
    public mutating func setORMValue(to value: ValueConvertible?, forKey key: String) {
        self[raw: key] = value
    }
}

extension MongoKitten.Collection : Table {
    public func find(matching query: Query?, sorted by: KittenORM.Sort?) throws -> AnyIterator<Document> {
        let mongoSort: MongoKitten.Sort?
        
        if let order = by?.order {
            var doc = Document()
            
            for (key, val) in order {
                if case .ascending = val {
                    doc[key] = Int32(1)
                } else {
                    doc[key] = Int32(-1)
                }
            }
            mongoSort = MongoKitten.Sort(doc)
            
        } else {
            mongoSort = nil
        }
        
        return try self.find(matching: query, sortedBy: mongoSort).makeIterator()
    }
    
    public func store(_ entity: Document) throws {
        try self.insert(entity)
    }
    
    public func findOne(matching query: Query?) throws -> Document? {
        return try self.findOne(matching: query, collation: nil)
    }
    
    public func findOne(byId identifier: ValueConvertible) throws -> Document? {
        return try self.findOne(matching: "_id" == identifier)
    }
    
    public func update(matching query: Query?, to entity: Document) throws {
        try self.update(matching: query ?? [:], to: entity, upserting: false, multiple: true)
    }
    
    public func update(matchingIdentifier identifier: ValueConvertible, to entity: Document) throws {
        try self.update(matching: "_id" == identifier, to: entity)
    }
    
    public static func generateId() -> ValueConvertible {
        return ObjectId()
    }

    public typealias Query = MongoKitten.Query
    public typealias Entity = Document
}

extension MongoKitten.Database : KittenORM.Database {
    public typealias T = MongoKitten.Collection
    
    public convenience init(_ connectionString: String) throws {
        try self.init(mongoURL: connectionString)
    }
    
    public func getTable(named collection: String) -> MongoKitten.Collection {
        return self[collection]
    }
}
