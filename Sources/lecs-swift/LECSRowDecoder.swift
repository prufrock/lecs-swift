//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/13/23.
//

import Foundation

class LECSRowDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    fileprivate var data: Data
    fileprivate var offset: Int = 0
    fileprivate var decoded: [LECSComponent] = []

    init(_ data: Data) {
        self.data = data
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError("Not implemented")
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        LECSRowUnkeyedDecodingContainer(decoder: self)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("Not implemented")
    }

    func decode(types: [LECSComponent.Type]) throws -> LECSRow {
        try types.forEach {
            let value = try $0.init(from: self)
            decoded.append(value)
        }

        return decoded
    }
}

class LECSRowUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? = nil
    var isAtEnd: Bool { currentIndex >= count! }
    var currentIndex: Int = 0

    var decoder: LECSRowDecoder

    init(decoder: LECSRowDecoder) {
        self.decoder = decoder
    }

    func decodeNil() throws -> Bool {
        fatalError("not implemented")
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        fatalError("not implemented")
    }

    func decode(_ type: String.Type) throws -> String {
        try decodeSimpleType(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try decodeSimpleType(type)
    }

    func decodeSimpleType<T>(_ type: T.Type) throws -> T where T : Decodable {
        let value = decoder.data[rangeToRead(type)].withUnsafeBytes {
            $0.load(as: T.self)
        }

        slideOffsetForward(type)

        return value
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    func superDecoder() throws -> Decoder {
        fatalError("not implemented")
    }

    private func rangeToRead<T>(_ type: T.Type) -> Range<Int> {
        decoder.offset..<decoder.offset + MemoryLayout<T>.stride
    }

    private func slideOffsetForward<T>(_ type: T.Type) {
        decoder.offset = decoder.offset + MemoryLayout<T>.stride
    }
}
