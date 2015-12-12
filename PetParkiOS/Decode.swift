//
//  Decode.swift
//  DecodeJSON
//
//  Created by Stan Mollov on 9/9/15.
//  Copyright © 2015 SiSo. All rights reserved.
//

import Foundation


typealias JSON = AnyObject

protocol Decodable {
    static func decodeJSON(json: JSON) throws -> Self
}

enum DecodeError: ErrorType {
    case MissingKey(msg: String)
    case TypeMismatch(msg: String)
}

// MARK: Decode simple property
func decode<U>(json: JSON, key: String) throws -> U {
    guard let property: JSON = json[key] else {
        throw DecodeError.MissingKey(msg: "Missing key \"\(key)\"")
    }
    
    if property is U {
        return property as! U
    } else {
        throw DecodeError.TypeMismatch(msg: "Property with Key: \"\(key)\" isn't of type: \(U.self)")
    }
}

// MARK: Decode property as optional
func decodeOptional<U>(json: JSON, key: String) throws -> U? {
    if let property = json[key] as? U {
        return property
    } else {
        return .None
    }
}

// MARK: Decode object as optional
func decodeOptional<U: Decodable>(json: JSON, key: String) throws -> U? {
    if let object: JSON = json[key] {
        return try U.decodeJSON(object)
    } else {
        return .None
    }
}

// MARK: Decode Nested object
func decode<U: Decodable>(json: JSON, key: String) throws -> U {
    guard let object: JSON = json[key] else {
        throw DecodeError.MissingKey(msg: "Missing object key \"\(key)\"")
    }
    
    return try U.decodeJSON(object)
}

// MARK: Decode array of decodable objects
func decode<U: Decodable>(json: JSON, key: String) throws -> [U] {
    guard let array: JSON = json[key] else {
        throw DecodeError.MissingKey(msg: "Missing array key \"\(key)\"")
    }
    
    guard let arrayJSON: [JSON] = array as? [JSON] else {
        throw DecodeError.TypeMismatch(msg: "Array property with key: \"\(key)\" isn't of type: \(U.self)")
    }
    
    var parsedArray: [U] = []
    
    for obj in arrayJSON {
        let parsedObj: U = try U.decodeJSON(obj)
        parsedArray.append(parsedObj)
    }
    
    return parsedArray
}

// MARK: Decode optional array of decodable objects
func decodeOptional<U: Decodable>(json: JSON, key: String) throws -> [U]? {
    guard let json: JSON = json else {
        return .None
    }
    
    guard let _ = json[key] as? [JSON] else {
        return .None
    }
    
    let v: [U] = try decode(json, key: key)
    return v
}

// MARK: Decode property from nested object
func decode<U>(json: JSON, keys: [String]) throws -> U {
    guard let nestedObj: JSON = json[keys[0]] else {
        throw DecodeError.MissingKey(msg: "Missing key \"\(keys[0])\"")
    }
    
    return try decode(nestedObj, key: keys[1])
}









