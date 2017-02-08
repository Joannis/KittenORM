@_exported import Cheetah
@_exported import KittenORM

extension JSONObject: SerializableObject {
    public static func convert<S : SerializableObject>(_ a: JSONValue, to b: S.Type) -> S.SupportedValue? {
        return a as? S.SupportedValue
    }

    public typealias SupportedValue = JSONValue
    public typealias ConvertibleValue = JSONValue
    
    public func getValue(forKey key: String) -> JSONValue? {
        return self[key]
    }
    
    public mutating func setValue(to newValue: JSONValue?, forKey key: String) {
        self[key] = newValue
    }
    
    public func getKeys() -> [String] {
        return self.keys
    }
    
    public func getValues() -> [JSONValue] {
        return self.values
    }
    
    public func getKeyValuePairs() -> [String : JSONValue] {
        return self.dictionaryValue
    }
    
    public init(dictionary: [String: JSONValue]) {
        self.init(dictionary)
    }
}
