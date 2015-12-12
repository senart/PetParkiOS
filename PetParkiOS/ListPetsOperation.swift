//
//  ListPetsOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/api/pets")!

protocol ListPetsDelegate: class {
    func didListPets(pets: [Pet])
}

class ListPetsOperation: URLSessionDataTaskOperation<PetParkList<Pet>>
{
    weak var delegate: ListPetsDelegate?
    
    init() {
        let urlRequest = URLRequest.init(url: URL, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List Pets Operation"
        
        self.onSuccess = { pets in
            self.delegate?.didListPets(pets.list)
        }
    }
}
