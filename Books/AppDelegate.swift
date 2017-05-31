//
//  AppDelegate.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 5. 10..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit
import FolioReaderKit
import GoogleMobileAds
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundSessionCompletionHandler : (() -> Void)?
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Util.setSessionId()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1966927625201357~9016686428")

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FolioReader.applicationWillResignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        FolioReader.applicationWillTerminate()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
}

