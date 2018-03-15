//
//  AppDelegate.swift
//  ELMapView
//
//  Created by Eduard Lev on 3/13/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

let googleApiKey = "AIzaSyAmrClNv9zGdieYo_7IAENGdlcEm5kZdYE"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(googleApiKey)
        // Override point for customization after application launch.
        return true
    }

    

}

