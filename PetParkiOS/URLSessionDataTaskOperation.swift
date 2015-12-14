//
//  URLSessionDataTaskOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

enum URLSessionResponseCode: Int {
    case Ok = 200
    case BadRequest = 400
    case Unauthorized = 401
    case InternalServerError = 500
}

struct URLRequest {
    let request: NSMutableURLRequest
    
    var bodyDataFields: [String:String]? {
        didSet{
            if let bodyDataFields = bodyDataFields{
                var bodyString = ""
                for field in bodyDataFields {
                    if bodyString == "" { bodyString = "\(field.0)=\(field.1)" }
                    else { bodyString = "\(bodyString)&\(field.0)=\(field.1)" }
                }
                let bodyData = bodyString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
                request.HTTPBody = bodyData
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }
    }
    
    var params: [String: AnyObject]? {
        didSet{
            var jsonError: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params!, options: .PrettyPrinted)
            } catch let error as NSError {
                jsonError = error
                request.HTTPBody = nil
            }
                
            assert(jsonError == nil, "There was an error when converting httpBody to JSON NSData.")
        }
    }
    
    init(url: NSURL, method: String = "POST", authorize: Bool = true) {
        request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        if authorize { request.setValue("Bearer \(Preferences.tokenID)", forHTTPHeaderField: "Authorization") }
    }
}

class URLSessionDataTaskOperation<T: Decodable>: Operation
{
    private(set) var task: NSURLSessionTask?
    
    var onSuccess: (T->Void)?
    var onFailure: (Int->String?)?
    var onNoParse: (()->Void)?
    
    init(request: NSURLRequest, noParse: Bool = false){
        super.init()
        
        name = "URL Data Task"
        addObserver(NetworkObserver())
        
        self.task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                self.taskFailedWithError(error.code, message: error.description)
                return
            }
            
            let responseCode = self.getResponseStatusCode(response)
            
            if responseCode != .Ok {
                self.taskFailedWithError(responseCode.rawValue, message: "\(responseCode)")
                return
            }
            
            if noParse { self.onNoParse?() }
            else {
                do {
                    let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let response = try T.decodeJSON(json)
                    
                    self.onSuccess?(response)
                }
                catch DecodeError.MissingKey(let msg) {
                    self.taskFailedWithError(0, message: msg)
                    return
                }
                catch DecodeError.TypeMismatch(let msg) {
                    self.taskFailedWithError(1, message: msg)
                    return
                }
                catch {
                    self.taskFailedWithError(2, message: "No json object from server")
                    return
                }
            }
            
            self.finish()
            
        }
    }
    
    override func execute() {
        assert(task?.state == .Suspended, "Task was resumed by something other than \(self)")
        task?.resume()
    }
    
    private func taskFailedWithError(code: Int, message: String) {
        let msg = self.onFailure?(code) ?? message
        print(message)
        cancelWithError(NSError(code: code, userInfo: [NSLocalizedDescriptionKey: msg]))
        finish()
    }
    
    private func getResponseStatusCode(response: NSURLResponse?) -> URLSessionResponseCode {
        if let httpResponse = response as? NSHTTPURLResponse, code = URLSessionResponseCode(rawValue: httpResponse.statusCode) {
            return code
        }
        return .InternalServerError
    }
}

extension NSError {
    convenience init(code: Int, userInfo: [NSObject: AnyObject]? = nil) {
        self.init(domain: "URLSessionDataTaskOperation", code: code, userInfo: userInfo)
    }
}