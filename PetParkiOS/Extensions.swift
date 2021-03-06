//
//  Extensions.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/12/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import Foundation

extension String {
    func isEmail() -> Bool {
        let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, self.characters.count)) != nil
        } catch { return false }
    }
}

extension UIImageView {
    
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode, success: ((UIImage)->Void)? = nil) {
        guard let url = NSURL(string: link) else { return }
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, _, error in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) {
                self.image = image
                success?(image)
            }
        }).resume()
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

struct Redirect { //Handles redictions with a generic function. There is an optional completion handler if the created view is needed
    static func toViewControllerWithIdentifier<T: UIViewController>(identifier: String, ofType: T, animated: Bool = true, completionHandler: ((T)->Void)? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let rootVC = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController as! UINavigationController
        if let targetVC = storyboard.instantiateViewControllerWithIdentifier(identifier) as? T {
            rootVC.pushViewController(targetVC, animated: animated)
            completionHandler?(targetVC)
        }
    }
}