//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

class LECSBinaryEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    var data: Data = Data(count: MemoryLayout<LECSId>.stride + MemoryLayout<LECSPosition2d>.stride)
    var index = 0

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        return KeyedEncodingContainer(BinaryKeyedEncodingContainer<Key>(encoder: self))
        fatalError("not implemented")
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return LECSBinaryUnkeyedEncodingContainer(encoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return BinarySingleValueEncodingContainer(encoder: self)
    }
}

class LECSBinaryUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int = 0

    var encoder: LECSBinaryEncoder

    init(encoder: LECSBinaryEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {
        fatalError("not implemented")
    }

    func encodeNullStruct(_ stride: Int) {
        var value = NSNull()
        let data = Data(bytes: &value, count: stride)

        for i in encoder.index..<encoder.index+stride {
            encoder.data[i] = data[i - encoder.index]
        }

        encoder.index = encoder.index + stride
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
        fatalError("not implemented")
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

    var encoder: LECSBinaryEncoder

    init(encoder: LECSBinaryEncoder) {
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
