//
//  AppInitializer.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/12.
//

import Foundation

class AppInitializer {
    private static let userDefaults = CSEDataManager.userDefaults
    private static let currentRegion = Locale.current.region?.identifier
    
    class func initializeApp() {
        let lastVersion: String = userDefaults.string(forKey: "LastAppVer") ?? ""
        let currentVersion = CSEDataManager.currentVersion
        
        let searchengine: String? = userDefaults.string(forKey: "searchengine") ?? nil
        let privsearchengine: String? = userDefaults.string(forKey: "privsearchengine") ?? nil
        let needSafariTutorial: Bool = userDefaults.bool(forKey: "needSafariTutorial")
        let needFirstTutorial: Bool = userDefaults.bool(forKey: "needFirstTutorial")
        
        // Initialize default settings
        if lastVersion == "" {
            userDefaults.set(SafariSEs.defaultForRegion(region: currentRegion).rawValue, forKey: "searchengine")
            userDefaults.set(SafariSEs.privateForRegion(region: currentRegion).rawValue, forKey: "privsearchengine")
            userDefaults.set(true, forKey: "alsousepriv")
            
            userDefaults.set(true, forKey: "iCloudAutoBackup")
            
            // Change default settings for macOS or under iOS 17
            #if targetEnvironment(macCatalyst)
            userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            #elseif os(iOS)
            if #unavailable(iOS 17.0) {
                userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            }
            #endif
            
            // Initialize CSEs
            resetCSE(target: "all")
        }
        
        // Update/Create database for v3.0 or later
        if lastVersion == "" || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
            migrateOldCSESettings()
        }
        
        // Create useDefaultCSE for v4.0 or later
        if lastVersion == "" || isUpdated(updateVer: "4.0", lastVer: lastVersion) {
            if userDefaults.string(forKey: "useDefaultCSE") == nil {
                userDefaults.set(true, forKey: "useDefaultCSE")
            }
        }
        
        // Automatically corrects settings to match OS version and region
        correctSafariSE(searchengine: searchengine, privsearchengine: privsearchengine)
        
        if needFirstTutorial && needSafariTutorial {
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(false, forKey: "needSafariTutorial")
        }
        
        // Save last opened version
        userDefaults.set(currentVersion, forKey: "LastAppVer")
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
    
    private class func correctSafariSE(searchengine: String?, privsearchengine: String?) {
        let currentSE = SafariSEs(rawValue: searchengine ?? "")
        let currentPrivateSE = SafariSEs(rawValue: privsearchengine ?? "")

        // Correct Default SE
        if let se = currentSE, !se.isAvailable(forRegion: currentRegion) {
            userDefaults.set(SafariSEs.defaultForRegion(region: currentRegion).rawValue, forKey: "searchengine")
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        if #available(iOS 17.0, macOS 14.0, *) {
            // Correct Private SE
            if let se = currentPrivateSE, !se.isAvailable(forRegion: currentRegion) {
                userDefaults.set(SafariSEs.privateForRegion(region: currentRegion).rawValue, forKey: "privsearchengine")
                userDefaults.set(true, forKey: "needSafariTutorial")
            }
        } else {
            userDefaults.set(true, forKey: "alsousepriv")
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
        guard !lastVer.isEmpty else { return false }
        
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
