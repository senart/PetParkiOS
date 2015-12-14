//
//  RegisterUserOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/14/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = NSURL(string: "\(APILink)/api/account/register")!

private let Email = "Email"
private let Password = "Password"
private let ConfirmPassword = "ConfirmPassword"

protocol RegisterUserOperationDelegate: class {
    func didRegisterUser()
    func registerFailure()
}

class RegisterUserOperation: URLSessionDataTaskOperation<NoParse>
{
    weak var delegate: RegisterUserOperationDelegate?
    
    init(email: String, password: String, repeatPassword: String) {
        var urlRequest = URLRequest(url: URL,method: "POST")
        urlRequest.bodyDataFields = [
            Email: email,
            Password: password,
            ConfirmPassword: repeatPassword
        ]
        
        super.init(request: urlRequest.request, noParse: true)
        
        name = "Register Operation"
        
        self.onNoParse = {
            self.delegate?.didRegisterUser()
        }
        
        self.onFailure = { _ in
            self.delegate?.registerFailure()
            return nil
        }
    }
}