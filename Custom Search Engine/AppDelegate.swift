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
        let currentRegion = Locale.current.regionCode
        
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
        let lastVersion = userDefaults!.string(forKey: "LastAppVer") ?? nil
        let searchengine = userDefaults!.string(forKey: "searchengine") ?? nil
        let privsearchengine = userDefaults!.string(forKey: "privsearchengine") ?? nil
        
        userDefaults!.set(true, forKey: "needFirstTutorial")
        if lastVersion == nil {
            userDefaults!.set(true, forKey: "needFirstTutorial")
            userDefaults!.set(true, forKey: "alsousepriv")
        }
        
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(searchengine))
           || (currentRegion != "RU" && ["yandex"].contains(searchengine)) {
            if currentRegion == "CN" {
                userDefaults!.set("baidu", forKey: "searchengine")
            } else {
                userDefaults!.set("google", forKey: "searchengine")
            }
        }
        
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(privsearchengine))
           || (currentRegion != "RU" && ["yandex"].contains(privsearchengine)) {
            if currentRegion == "CN" {
                if searchengine == "duckduckgo" {
                    userDefaults!.set("baidu", forKey: "privsearchengine")
                } else {
                    userDefaults!.set("duckduckgo", forKey: "privsearchengine")
                }
            } else {
                if searchengine == "duckduckgo" {
                    userDefaults!.set("google", forKey: "privsearchengine")
                } else {
                    userDefaults!.set("duckduckgo", forKey: "privsearchengine")
                }
            }
        }

        userDefaults!.set(currentVersion, forKey: "LastAppVer")
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

