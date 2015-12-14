//
//  UpdateUserLocationOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/14/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/api/account/updateLocation")!

class UpdateUserLocationOperation: URLSessionDataTaskOperation<NoParse>
{
    init(latitude: String, longitude: String) {
        var urlRequest = URLRequest.init(url: URL)
        
        urlRequest.params = [
            "Latitude": latitude,
            "Longitude": longitude
        ]
        
        super.init(request: urlRequest.request)
        
        name = "Update User Location Operation"
    }
}