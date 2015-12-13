//
//  Breed.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/13/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

final class Breed: Decodable
{
    let breedID: String
    
    init(breedID: String) {
        self.breedID = breedID
    }
    
    static func decodeJSON(json: JSON) throws -> Breed {
        return Breed(breedID: try decode(json, key: "BreedID"))
    }
}