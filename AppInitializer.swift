//
//  AppInitializer.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/12.
//

import Foundation

class AppInitializer {
    private static let userDefaults = CSEDataManager.userDefaults
    
    class func initializeApp() {
        let lastVersion: String = userDefaults.string(forKey: "LastAppVer") ?? ""
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentRegion = Locale.current.region?.identifier
        
        let searchengine: String? = userDefaults.string(forKey: "searchengine") ?? nil
        let privsearchengine: String? = userDefaults.string(forKey: "privsearchengine") ?? nil
        let adv_resetCSEs: String = userDefaults.string(forKey: "adv_resetCSEs") ?? ""
        let needSafariTutorial: Bool = userDefaults.bool(forKey: "needSafariTutorial")
        let needFirstTutorial: Bool = userDefaults.bool(forKey: "needFirstTutorial")
        
        // adv_resetCSEs
        if adv_resetCSEs != "" {
            resetCSE(target: adv_resetCSEs)
            userDefaults.set("", forKey: "adv_resetCSEs")
        }
        
        // Initialize default settings
        if lastVersion == "" {
            userDefaults.set("google", forKey: "searchengine")
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            userDefaults.set(true, forKey: "alsousepriv")
        }
        
        // Update/Create database for v3.0 or later
        if lastVersion == "" || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
            performV3Updates()
            migrateOldCSESettings()
        }
        
        // Create useDefaultCSE for v4.0 or later
        if lastVersion == "" || isUpdated(updateVer: "4.0", lastVer: lastVersion) {
            if userDefaults.string(forKey: "useDefaultCSE") == nil {
                userDefaults.set(true, forKey: "useDefaultCSE")
            }
        }
        
        // Automatically corrects settings to match OS version
        performOSVersionCorrections(lastVersion: lastVersion, searchengine: searchengine, currentRegion: currentRegion)
        
        // Fix search engines by region
        fixSearchEnginesByRegion(searchengine: searchengine, privsearchengine: privsearchengine, currentRegion: currentRegion)
        
        if needFirstTutorial && needSafariTutorial {
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(false, forKey: "needSafariTutorial")
        }
        
        // Save last opened version
        userDefaults.set(currentVersion, forKey: "LastAppVer")
    }
    
    private class func performV3Updates() {
        // Change default settings for macOS or under iOS 17
        #if macOS
        userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
        #endif
        if #unavailable(iOS 17.0) {
            userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
        }
        
        // Initialize settings
        resetCSE(target: "all")
    }
    
    private class func migrateOldCSESettings() {
        // Update old CSE settings
        let urltop: String = userDefaults.string(forKey: "urltop") ?? ""
        let urlsuffix: String = userDefaults.string(forKey: "urlsuffix") ?? ""
        if (urltop != "" || urlsuffix != "") {
            let defaultCSE = CSEDataManager.CSEData(url: urltop + "%s" + urlsuffix)
            CSEDataManager.saveCSEData(defaultCSE, .defaultCSE)
            userDefaults.removeObject(forKey: "urltop")
            userDefaults.removeObject(forKey: "urlsuffix")
        }
    }
    
    private class func performOSVersionCorrections(lastVersion: String, searchengine: String?, currentRegion: String?) {
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
    }
    
    private class func fixSearchEnginesByRegion(searchengine: String?, privsearchengine: String?, currentRegion: String?) {
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
    }
    
    // Reset CSEs | target == 'all' or 'default' or 'private' or 'quick'
    class func resetCSE(target: String) {
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
    private class func isUpdated(updateVer: String, lastVer: String) -> Bool {
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
