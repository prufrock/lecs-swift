//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/11/23.
//

import Foundation

class LECSRowEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    fileprivate var data: Data
    fileprivate var offset: Int = 0

    init(_ count: Int) {
        self.data = Data(count: count)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError("Not implemented")
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        LECSRowUnkeyedEncodingContainer(encoder: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Not implemented")
    }

    func encode(_ value: LECSRow) throws -> Data {
        try value.forEach {
            try $0.encode(to: self)
        }

        return data
    }
}

class LECSRowUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int = 0

    var encoder: LECSRowEncoder

    init(encoder: LECSRowEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {
        fatalError("not implemented")
    }

    func encode(_ value: Bool) throws {
        fatalError("not implemented")
    }

    func encode(_ value: String) throws {
        try encodeSimpleType(value)
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
        try encodeSimpleType(value)
    }

    func encodeSimpleType<T>(_ value: T) throws {
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<T>.stride)

        for i in encoder.offset..<encoder.offset+MemoryLayout<T>.stride {
            encoder.data[i] = data[i - encoder.offset]
        }

        encoder.offset = encoder.offset + MemoryLayout<T>.stride
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
