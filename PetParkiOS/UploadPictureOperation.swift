//
//  UploadPictureOperation.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

private let URL = "\(APILink)/api/pets/"

protocol UploadPictureDelegate: class {
    func didUploadImage(uploadedPetImage: PetImage)
}

class UploadPictureOperation: URLSessionDataTaskOperation<PetImage>
{
    weak var delegate: UploadPictureDelegate?
    
    init(id: Int, jpgImageData: NSData) {
        
        let url = NSURL(string: "\(URL)\(id)/uploadImage")!
        let uploadRequest = URLUploadRequest(url: url, jpgImageData: jpgImageData)
        
        super.init(request: uploadRequest.request)
        
        name = "URL Upload Data Task"
        
        self.onSuccess = { uploadedPetImage in
            self.delegate?.didUploadImage(uploadedPetImage)
        }
    }
}

class URLUploadRequest {
    let request: NSMutableURLRequest
    
    init(url: NSURL, jpgImageData: NSData, authorize: Bool = true) {
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("Bearer \(Preferences.tokenID)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createBodyWithParameters("file", imageDataKey: jpgImageData, boundary: boundary)
    }
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
}