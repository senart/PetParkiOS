//
//  AddPetOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/13/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/api/pets")!

protocol CreatePetOperationDelegate: class {
    func didFinishCreatingPet(success: Bool)
}

class CreatePetOperation: URLSessionDataTaskOperation<NoParse>
{
    weak var delegate: CreatePetOperationDelegate?
    
    init(petName: String, gender: String, species: String, breed: String, age: String, weight: String) {
        var urlRequest = URLRequest.init(url: URL)
        
        urlRequest.params = [
            "Species": species,
            "Breed": breed,
            "Gender": gender,
            "Name": petName,
            "Age": age,
            "Weight": weight,
        ]
        
        super.init(request: urlRequest.request)
        
        name = "Create Pet Operation"
        
        onSuccess = { _ in
            self.delegate?.didFinishCreatingPet(true)
        }
        onFailure = { _ in
            self.delegate?.didFinishCreatingPet(false)
            return nil
        }
    }
}