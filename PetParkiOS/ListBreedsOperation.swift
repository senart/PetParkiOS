//
//  ListBreedsOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/13/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/breeds"

protocol ListBreedsDelegate: class {
    func didListBreeds(breeds: [Breed])
}

class ListBreedsOperation: URLSessionDataTaskOperation<PetParkList<Breed>>
{
    weak var delegate: ListBreedsDelegate?
    
    init(speciesID: String) {
        let url = NSURL(string: "\(URL)/\(speciesID)")!
        let urlRequest = URLRequest(url: url, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List Breeds Operation"
        
        self.onSuccess = { breeds in
            self.delegate?.didListBreeds(breeds.list)
        }
    }
}