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