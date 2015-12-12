//
//  AppDelegate.swift
//  PetParkiOS
//
//  Created by Gavril Tonev on 12/11/15.
//  Copyright © 2015 Gavril Tonev. All rights reserved.
//

import UIKit

public let APILink = "http://petpark.azurewebsites.net"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Preferences.reset()  // FIX: delete this
        Preferences.registerDefaults()
        checkForUserDetails()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkForUserDetails(){  //If we have the following data we will be redirected, otherwise we go to SignInViewController (default)
        if !Preferences.tokenID.isEmpty {
            Redirect.toViewControllerWithIdentifier("Reveal", ofType: SWRevealViewController(), animated: false)
        }
    }
    
    struct Redirect { //Handles redictions with a generic function. There is an optional completion handler if the created view is needed
        static func toViewControllerWithIdentifier<T: UIViewController>(identifier: String, ofType: T, animated: Bool = true, completionHandler: ((T)->Void)? = nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let rootVC = (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController as! UINavigationController
            let targetVC = storyboard.instantiateViewControllerWithIdentifier(identifier) as? T
            if let targetVC = targetVC {
                rootVC.pushViewController(targetVC, animated: animated)
                completionHandler?(targetVC)
            }
        }
    }

}

