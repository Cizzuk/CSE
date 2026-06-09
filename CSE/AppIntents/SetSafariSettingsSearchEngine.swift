//
//  SetSafariSettingsSearchEngine.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/05/27.
//

import AppIntents

struct SetSafariSettingsSearchEngine: AppIntent {
    static var title: LocalizedStringResource = "Set Safari's Search Engine"
    static var description: LocalizedStringResource = "Please configure the settings to match the actual Safari settings."
    
    @Parameter(title: "Search Engine", default: "Google")
    var defaultSE: String
    
    @Parameter(title: "Also Use in Private Browsing", default: true)
    var alsoUsePrivate: Bool
    
    @Parameter(title: "Private Search Engine", default: "")
    var privateSE: String
    
    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        
        if let engine = SafariSEs.convertForShortcuts(defaultSE) {
            userDefaults.set(engine.rawValue, forKey: "searchengine")
        }
        
        userDefaults.set(alsoUsePrivate, forKey: "alsousepriv")
        
        if let engine = SafariSEs.convertForShortcuts(privateSE) {
            userDefaults.set(engine.rawValue, forKey: "privsearchengine")
        }
        
        return .result()
    }
}
