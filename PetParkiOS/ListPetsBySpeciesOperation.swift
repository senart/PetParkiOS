//
//  ListPetsBySpeciesOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/13/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/pets"

protocol ListPetsBySpeciesDelegate: class {
    func didListPetsBySpecies(pets: [Pet])
}

class ListPetsBySpeciesOperation: URLSessionDataTaskOperation<PetParkList<Pet>>
{
    weak var delegate: ListPetsBySpeciesDelegate?
    
    init(speciesID: String) {
        let url = NSURL(string: "\(URL)/\(speciesID)/byspecies")!
        let urlRequest = URLRequest(url: url, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List Pets By Species Operation"
        
        self.onSuccess = { pets in
            self.delegate?.didListPetsBySpecies(pets.list)
        }
    }
}









