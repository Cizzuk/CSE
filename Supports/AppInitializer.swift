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
    
    class func initializeApp() {
        let lastVersion = userDefaults.string(forKey: "LastAppVer") ?? ""
        
        let isFirstLaunch = lastVersion.isEmpty
        let isVersionChanged = lastVersion != currentVersion
        
        // Early exit if no changes detected
        if !isFirstLaunch && !isVersionChanged {
            return
        }
        
        // First Launch Setup
        if isFirstLaunch {
            userDefaults.set(true, forKey: "needFirstTutorial")
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
            
            // Quick Search Settings for v4.8+
            if isFirstLaunch || isUpdated(updateVer: "4.8", lastVer: lastVersion) {
                if userDefaults.string(forKey: "QuickSearchSettings_keywordOnly") == nil {
                    // Migrate from adv_disableKeywordOnlyQuickSearch
                    let advSetting = userDefaults.bool(forKey: "adv_disableKeywordOnlyQuickSearch")
                    userDefaults.set(!advSetting, forKey: "QuickSearchSettings_keywordOnly")
                    userDefaults.removeObject(forKey: "adv_disableKeywordOnlyQuickSearch")
                }
                if userDefaults.string(forKey: "QuickSearchSettings_keywordPos") == nil {
                    userDefaults.set(QuickSearchKeywordPos.default.rawValue, forKey: "QuickSearchSettings_keywordPos")
                }
            }
        }
        
        // Save Current State
        DispatchQueue.global(qos: .background).async {
            userDefaults.set(currentVersion, forKey: "LastAppVer")
        }
    }
    
    // MARK: - Migration Helpers
    
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
    
    // MARK: - Reset CSE Data
    
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
