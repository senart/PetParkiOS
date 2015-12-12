//
//  PetParkList.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

final class PetParkList<T: Decodable>: Decodable {
    let list: [T]
    
    init(list: [T]) {
        self.list = list
    }
    
    static func decodeJSON(j: JSON) throws -> PetParkList {
        var ar = [T]()
        if let jsonArray = j as? NSArray {
            for jsonItem in jsonArray {
                ar.append(try T.decodeJSON(jsonItem))
            }
            return PetParkList(list: ar)
        }
        throw DecodeError.TypeMismatch(msg: "Parse PetParkList failed at casting to NSArray")
    }
}