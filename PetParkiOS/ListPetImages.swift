//
//  ListPetImages.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/pets"

protocol ListPetImagesDelegate: class {
    func didListPetImages(pets: [PetImage])
}

class ListPetImagesOperation: URLSessionDataTaskOperation<PetParkList<PetImage>>
{
    weak var delegate: ListPetImagesDelegate?
    
    init(id: Int) {
        let url = NSURL(string: "\(URL)/\(id)/images")!
        let urlRequest = URLRequest.init(url: url, method: "GET")
        
        super.init(request: urlRequest.request)
        
        name = "List User Pets Operation"
        
        self.onSuccess = { petImages in
            self.delegate?.didListPetImages(petImages.list)
        }
    }
}