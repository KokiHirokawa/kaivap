//
//  AppDelegate.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/01/29.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let APIKey = "AIzaSyCz8lY-HE6f5XIzLrX8LHAVSrGYDy9Bwjg"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(APIKey)
        GMSPlacesClient.provideAPIKey(APIKey)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

