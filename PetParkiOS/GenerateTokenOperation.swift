//
//  GetTokenOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/token")!

private let Grant_Type = "grant_type"
private let Email = "userName"
private let Password = "password"

protocol GenerateTokenOperationDelegate: class {
    func didGenerateToken(token: Token)
    func accessDenied()
}

class GenerateTokenOperation: URLSessionDataTaskOperation<Token>
{
    weak var delegate: GenerateTokenOperationDelegate?
    
    init(email: String, password: String) {
        var urlRequest = URLRequest(url: URL,method: "POST")
        urlRequest.bodyDataFields = [
            Grant_Type: "password",
            Email: email,
            Password: password
        ]
        
        super.init(request: urlRequest.request)
        
        name = "Login Operation"
        
        self.onSuccess = { token in
            self.delegate?.didGenerateToken(token)
        }
        
        self.onFailure = { code in
            if let statusCode = URLSessionResponseCode(rawValue: code) where statusCode == .BadRequest {
                self.delegate?.accessDenied()
                return "Unknown username or password"
            } else { return nil }
        }
    }
}