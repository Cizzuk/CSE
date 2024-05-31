//
//  AppDelegate.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

#if iOS
import UIKit
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let userDefaults = UserDefaults.standard
        userDefaults.set(currentVersion, forKey: "LastAppVer")
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
#endif
