//
//  AppDelegate.swift
//  On The Map
//
//  Created by Vinicius Carvalho on 12/09/2016.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    // configuration object
    var config = Config()
    
    // authentication state
    var sharedSession = NSURLSession.sharedSession()
    var requestToken: String? = nil
    var accountRegistered: Int? = nil
    var accountKey: AnyObject? = nil
    var sessionExpiration: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    var keyID: Int? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mediaUrl: String? = nil
    var mapString: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FIRApp.configure()
        // Override point for customization after application launch.
//        config.updateIfDaysSinceUpdateExceeds(7)
        return true
    }

}

extension AppDelegate {
    
    func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Client.Constants.Scheme.ApiScheme
        components.host = Client.Constants.Scheme.ApiHost
        components.path = Client.Constants.Scheme.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }

}

