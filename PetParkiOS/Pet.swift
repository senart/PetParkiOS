//
//  Pet.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

final class Pet: Decodable {
    
    let id: Int
    let species: String
    let breed: String
    let gender: String
    let name: String
    let age: Int
    let weight: Double
    let profilePicURL: String?
    var profilePic: UIImage? = nil
    let latitude: Double
    let longitude: Double
    
    init(id: Int, species: String, breed: String, gender: String, name: String, age: Int, weight: Double, profilePicURL: String?, latitude: Double, longitude: Double) {
        self.id = id
        self.species = species
        self.breed = breed
        self.gender = gender
        self.name = name
        self.age = age
        self.weight = weight
        self.profilePicURL = profilePicURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func decodeJSON(json: JSON) throws -> Pet {
        return Pet(
            id: try decode(json, key: "PetID"),
            species: try decode(json, key: "Species"),
            breed: try decode(json, key: "Breed"),
            gender: try decode(json, key: "Gender"),
            name: try decode(json, key: "Name"),
            age: try decode(json, key: "Age"),
            weight: try decode(json, key: "Weight"),
            profilePicURL: try decodeOptional(json, key: "ProfilePic"),
            latitude: try decode(json, key: "Latitude"),
            longitude: try decode(json, key: "Longitude")
        )
    }
}