//
//  Preferences.swift
//  eDynamix
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

private let PreferencesTokenID           = "PreferencesTokenID"
private let PreferencesTokenIsAuthorised = "PreferencesTokenIsAuthorised"
private let PreferencesKeyUserID         = "PreferencesKeyUserID"

final class Preferences {
    
    //MARK: Properties
    private class var standardUserDefaults: NSUserDefaults {
        get {
            return NSUserDefaults.standardUserDefaults()
        }
    }

    class var tokenID: String {
        get { return standardUserDefaults.stringForKey(PreferencesTokenID)! }
        set { standardUserDefaults.setObject(newValue, forKey: PreferencesTokenID) }
    }

    class var tokenIsAuthorised: Bool {
        get { return standardUserDefaults.boolForKey(PreferencesTokenIsAuthorised) }
        set { standardUserDefaults.setBool(newValue, forKey: PreferencesTokenIsAuthorised) }
    }

    class var userID: NSNumber {
        get { return standardUserDefaults.objectForKey(PreferencesKeyUserID) as! NSNumber }
        set { standardUserDefaults.setObject(newValue, forKey: PreferencesKeyUserID) }
    }
    
    // Use this on App Delegate to set default settings for the application
    class func registerDefaults() {
        var defaultPreferences: [String: AnyObject] = [:]
        
        defaultPreferences[PreferencesTokenID]           = ""
        defaultPreferences[PreferencesTokenIsAuthorised] = false
        defaultPreferences[PreferencesKeyUserID]         = NSNumber(int: -1)
        
        standardUserDefaults.registerDefaults(defaultPreferences)
    }
    
    class func reset() {
        let domainName = NSBundle.mainBundle().bundleIdentifier
        standardUserDefaults.removePersistentDomainForName(domainName!)
        Preferences.registerDefaults()
    }
}






