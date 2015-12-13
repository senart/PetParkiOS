//
//  NoParse.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

final class NoParse: Decodable {
    
    static func decodeJSON(json: JSON) throws -> NoParse {
        return NoParse()
    }
}