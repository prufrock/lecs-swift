import XCTest
@testable import lecs_swift

final class lecs_swiftTests: XCTestCase {

    func testExampleData() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(lecs_swift().text, "Hello, World!")

        let encoder = BinaryEncoder()

        let id = Id(id: 10)
        let position = Position(x: 5, y: 25)

        try! id.encode(to: encoder)
        try! position.encode(to: encoder)

        // read the id struct from the start of the buffer
        let id2 = encoder.data.withUnsafeBytes {
            $0.load(as: Id.self)
        }

        // read the position struct after the id struct from the buffer
        let position2 = encoder.data.withUnsafeBytes {
            $0.load(fromByteOffset: MemoryLayout<Id>.stride, as: Position.self)
        }

        XCTAssertEqual(10, id2.id)
        XCTAssertEqual(5, position2.x)
        XCTAssertEqual(25, position2.y)
    }
}

class BinaryEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    var data: Data = Data(count: MemoryLayout<Id>.stride + MemoryLayout<Position>.stride)
    var index = 0

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        return KeyedEncodingContainer(BinaryKeyedEncodingContainer<Key>(encoder: self))
        fatalError("not implemented")
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return BinaryUnkeyedEncodingContainer(encoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return BinarySingleValueEncodingContainer(encoder: self)
    }
}

class BinaryUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int = 0

    var encoder: BinaryEncoder

    init(encoder: BinaryEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {
        fatalError("not implemented")
    }

    func encode(_ value: Bool) throws {
        fatalError("not implemented")
    }

    func encode(_ value: String) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Double) throws {
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<Double>.stride)

        for i in encoder.index..<encoder.index+MemoryLayout<Double>.stride {
            encoder.data[i] = data[i - encoder.index]
        }

        encoder.index = encoder.index + MemoryLayout<Double>.stride
    }

    func encode(_ value: Float) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int) throws {
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<Int>.stride)

        for i in encoder.index..<encoder.index+MemoryLayout<Int>.stride {
            encoder.data[i] = data[i - encoder.index]
        }

        encoder.index = encoder.index + MemoryLayout<Int>.stride
    }

    func encode(_ value: Int8) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int16) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int32) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int64) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt) throws {
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<UInt>.stride)

        for i in encoder.index..<encoder.index+MemoryLayout<UInt>.stride {
            encoder.data[i] = data[i - encoder.index]
        }

        encoder.index = encoder.index + MemoryLayout<UInt>.stride
    }

    func encode(_ value: UInt8) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt16) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt32) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt64) throws {
        fatalError("not implemented")
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: encoder)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }

    func superEncoder() -> Encoder {
        fatalError("not implemented")
    }
}

class BinarySingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []

    var encoder: BinaryEncoder

    init(encoder: BinaryEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {
        fatalError("not implemented")
    }

    func encode(_ value: Bool) throws {
        fatalError("not implemented")
    }

    func encode(_ value: String) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Double) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Float) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int8) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int16) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int32) throws {
        fatalError("not implemented")
    }

    func encode(_ value: Int64) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt) throws {
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<UInt>.stride)

        for i in encoder.index..<encoder.index+MemoryLayout<UInt>.stride {
            encoder.data[i] = data[i - encoder.index]
        }

        encoder.index = encoder.index + MemoryLayout<UInt>.stride
    }

    func encode(_ value: UInt8) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt16) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt32) throws {
        fatalError("not implemented")
    }

    func encode(_ value: UInt64) throws {
        fatalError("not implemented")
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: encoder)
    }
}
struct Id: Codable {
    var id: UInt

    init(id: UInt) {
        self.id = id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decode(UInt.self)
    }
}

struct Position: Codable {
    var x: Int
    var y: Int
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }

    init (x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        x = try container.decode(Int.self)
        y = try container.decode(Int.self)
    }
}
