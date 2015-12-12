//
//  ListUserPetsOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/api/account/pets")!

protocol ListUserPetsDelegate: class {
    func didListUserPets(pets: [Pet])
}

class ListUserPetsOperation: URLSessionDataTaskOperation<PetParkList<Pet>>
{
    weak var delegate: ListUserPetsDelegate?
    
    init() {
        let urlRequest = URLRequest.init(url: URL, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List User Pets Operation"
        
        self.onSuccess = { pets in
            self.delegate?.didListUserPets(pets.list)
        }
    }
}