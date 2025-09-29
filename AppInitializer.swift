//
//  AppInitializer.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/12.
//

import Foundation

class AppInitializer {
    private static let userDefaults = CSEDataManager.userDefaults
    private static let currentVersion = CSEDataManager.currentVersion
    private static let currentRegion = Locale.current.region?.identifier
    
    class func initializeApp() {
        let lastVersion = userDefaults.string(forKey: "LastAppVer") ?? ""
        let lastRegion = userDefaults.string(forKey: "LastRegion") ?? ""
        let lastLanguages = userDefaults.array(forKey: "LastLanguages") as? [String] ?? []
        let currentLanguages = Locale.preferredLanguages
        
        let isFirstLaunch = lastVersion.isEmpty
        let isVersionChanged = lastVersion != currentVersion
        let isRegionChanged = lastRegion != currentRegion
        let isLanguageChanged = Set(lastLanguages) != Set(currentLanguages)
        
        // Early exit if no changes detected
        if !isFirstLaunch && !isVersionChanged && !isRegionChanged && !isLanguageChanged {
            return
        }
        
        // First Launch Setup
        if isFirstLaunch {
            userDefaults.set(SafariSEs.default.rawValue, forKey: "searchengine")
            userDefaults.set(SafariSEs.private.rawValue, forKey: "privsearchengine")
            userDefaults.set(true, forKey: "alsousepriv")
            userDefaults.set(true, forKey: "iCloudAutoBackup")
            
            resetCSE(target: .all)
        }
        
        // Version Update Tasks
        if isVersionChanged {
            // Database migration for v3.0+
            if isFirstLaunch || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
                migrateOldCSESettings()
            }
            
            // useDefaultCSE setting for v4.0+
            if isFirstLaunch || isUpdated(updateVer: "4.0", lastVer: lastVersion) {
                if userDefaults.string(forKey: "useDefaultCSE") == nil {
                    userDefaults.set(true, forKey: "useDefaultCSE")
                }
            }
        }
        
        // Langs & Region Update Tasks
        if isFirstLaunch || isRegionChanged || isLanguageChanged {
            let searchengine = userDefaults.string(forKey: "searchengine")
            let privsearchengine = userDefaults.string(forKey: "privsearchengine")
            correctSafariSE(searchengine: searchengine, privsearchengine: privsearchengine)
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        
        // If both tutorials are needed, only keep needFirstTutorial
        let needFirstTutorial = userDefaults.bool(forKey: "needFirstTutorial")
        let needSafariTutorial = userDefaults.bool(forKey: "needSafariTutorial")
        if needFirstTutorial && needSafariTutorial {
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(false, forKey: "needSafariTutorial")
        }
        
        // Save Current State
        userDefaults.set(currentVersion, forKey: "LastAppVer")
        userDefaults.set(currentRegion, forKey: "LastRegion")
        userDefaults.set(currentLanguages, forKey: "LastLanguages")
    }
    
    private class func migrateOldCSESettings() {
        let urltop = userDefaults.string(forKey: "urltop") ?? ""
        let urlsuffix = userDefaults.string(forKey: "urlsuffix") ?? ""
        if !urltop.isEmpty || !urlsuffix.isEmpty {
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
        if let se = currentSE, !se.isAvailable {
            userDefaults.set(SafariSEs.default.rawValue, forKey: "searchengine")
        }
        
        if #available(iOS 17.0, macOS 14.0, *) {
            // Correct Private SE
            if let se = currentPrivateSE, !se.isAvailable {
                userDefaults.set(SafariSEs.private.rawValue, forKey: "privsearchengine")
            }
        } else {
            userDefaults.set(true, forKey: "alsousepriv")
        }
    }
    
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
    
    // Reset CSEs | target == 'all' or 'default' or 'private' or 'quick'
    enum resetCSETarget {
        case all, defaultCSE, privateCSE, quickCSE
    }
    
    class func resetCSE(target: resetCSETarget) {
        switch target {
        case .all:
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .defaultCSE, uploadCloud: false)
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .privateCSE, uploadCloud: false)
            CSEDataManager.replaceQuickCSEData(RecommendSEs.quickCSEs())
        case .defaultCSE:
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .defaultCSE, uploadCloud: false)
        case .privateCSE:
            CSEDataManager.saveCSEData(CSEDataManager.CSEData(), .privateCSE, uploadCloud: false)
        case .quickCSE:
            CSEDataManager.replaceQuickCSEData(RecommendSEs.quickCSEs())
        }
    }
}
