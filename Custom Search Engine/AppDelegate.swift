//
//  AppDelegate.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

import UIKit
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
        let lastVersion = userDefaults!.string(forKey: "LastAppVer") ?? nil
        let urltop = userDefaults!.string(forKey: "urltop") ?? nil
        let urlsuffix = userDefaults!.string(forKey: "urlsuffix") ?? nil
        let searchengine = userDefaults!.string(forKey: "searchengine") ?? nil
        
        if lastVersion == nil && (urltop != nil || urlsuffix != nil) && searchengine == nil {
            userDefaults!.set("duckduckgo", forKey: "searchengine")
        }

        userDefaults!.set(currentVersion, forKey: "LastAppVer")
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

