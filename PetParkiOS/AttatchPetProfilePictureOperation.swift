//
//  UpdateProfilePictureOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/pets"

private let PetImageID = "PetImageID"

class AttatchPetProfilePictureOperation: URLSessionDataTaskOperation<NoParse>
{
    init(id: Int, petImageID: Int) {
        let url = NSURL(string: "\(URL)/\(id)/attatchprofileimage")!
        var urlRequest = URLRequest.init(url: url)
        
        urlRequest.params = [
            PetImageID: petImageID
        ]
        
        super.init(request: urlRequest.request)
        
        name = "Attatch Pet Profile Picture Operation"
    }
}