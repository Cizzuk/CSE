//
//  AppDelegate.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

import UIKit
import StoreKit

// Global constants
let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let currentRegion = Locale.current.region?.identifier
let userDefaults = CSEDataManager.userDefaults

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Get userDefaults
        let lastVersion: String = userDefaults.string(forKey: "LastAppVer") ?? ""
        let searchengine: String? = userDefaults.string(forKey: "searchengine") ?? nil
        let privsearchengine: String? = userDefaults.string(forKey: "privsearchengine") ?? nil
        let urltop: String = userDefaults.string(forKey: "urltop") ?? ""
        let urlsuffix: String = userDefaults.string(forKey: "urlsuffix") ?? ""
        let adv_resetCSEs: String = userDefaults.string(forKey: "adv_resetCSEs") ?? ""
        
        // adv_resetCSEs
        if adv_resetCSEs != "" {
            resetCSE(target: adv_resetCSEs)
            userDefaults.set("", forKey: "adv_resetCSEs")
        }
        
        // Update/Create database for v3.0 or later
        if lastVersion == "" || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
            // Change default settings for macOS or under iOS 17
            #if macOS
            userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            #endif
            if #unavailable(iOS 17.0) {
                userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            }
            
            // Initialize settings
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(true, forKey: "alsousepriv")
            if searchengine == nil {
                userDefaults.set("google", forKey: "searchengine")
            }
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            resetCSE(target: "all")
            
            // Update old CSE settings
            if (urltop != "" || urlsuffix != "") {
                var defaultCSE = CSEDataManager.CSEData()
                defaultCSE.url = urltop + "%s" + urlsuffix
                CSEDataManager.saveCSEData(defaultCSE, .defaultCSE)
                userDefaults.removeObject(forKey: "urltop")
                userDefaults.removeObject(forKey: "urlsuffix")
            }
        }
        
        // Automatically corrects settings to match OS version
        // Cannot use Google under iOS 17
        if #unavailable(iOS 17.0, macOS 14.0) {
            if searchengine == "google" || searchengine == nil {
                if currentRegion == "CN" {
                    userDefaults.set("baidu", forKey: "searchengine")
                } else {
                    userDefaults.set("bing", forKey: "searchengine")
                }
                if isUpdated(updateVer: "3.3", lastVer: lastVersion) {
                    userDefaults.set(true, forKey: "needSafariTutorial")
                }
            }
            userDefaults.set(true, forKey: "alsousepriv")
        }
        
        // Fix Default SE by region
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(searchengine))
            || (currentRegion != "RU" && ["yandex"].contains(searchengine)) {
            if currentRegion == "CN" {
                userDefaults.set("baidu", forKey: "searchengine")
            } else {
                userDefaults.set("google", forKey: "searchengine")
            }
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        
        // Fix Private SE by region
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(privsearchengine))
            || (currentRegion != "RU" && ["yandex"].contains(privsearchengine)) {
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        
        // Save last opened version
        userDefaults.set(currentVersion, forKey: "LastAppVer")
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // Reset CSEs | target == 'all' or 'default' or 'private' or 'quick'
    private func resetCSE(target: String) {
        // Save Data
        if target == "default" || target == "all" {
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .defaultCSE, uploadCloud: false)
        }
        if target == "private" || target == "all" {
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .privateCSE, uploadCloud: false)
        }
        if target == "quick" || target == "all" {
            CSEDataManager.replaceQuickCSEData(RecommendSEs.quickCSEs())
        }
    }
    
    // Version high and low
    private func isUpdated(updateVer: String, lastVer: String) -> Bool {
        guard lastVer != "" else {
            return false
        }
        
        let updateComponents = updateVer.split(separator: ".").compactMap { Int($0) }
        let lastComponents = lastVer.split(separator: ".").compactMap { Int($0) }
        
        for (update, last) in zip(updateComponents, lastComponents) {
            if update > last {
                return true
            } else if update < last {
                return false
            }
        }
        
        return updateComponents.count > lastComponents.count
    }
}
