//
//  PetImage.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

final class PetImage: Decodable
{
    let id: Int
    let petID: Int
    let imageURL: String
    var image: UIImage? = nil
    
    init(id: Int, petID: Int, imageURL: String) {
        self.id = id
        self.petID = petID
        self.imageURL = imageURL
    }
    
    static func decodeJSON(j: JSON) throws -> PetImage {
        return PetImage(
            id: try decode(j, key: "PetImageID"),
            petID: try decode(j, key: "PetID"),
            imageURL: try decode(j, key: "ImageURL")
        )
    }
}