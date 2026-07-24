//
//  IntentSupport.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import AppIntents

final class IntentSupport {
    static func isAllowedEditingSearchEngines() -> Bool {
        !CSEDataManager.userDefaults.bool(forKey: "adv_disableEditSEFromShortcuts")
    }
    
    enum CSEIntentError: LocalizedError {
        case notAllowedEditingSearchEngines
        
        var errorDescription: LocalizedStringResource? {
            switch self {
            case .notAllowedEditingSearchEngines:
                return "Editing Search Engines from Shortcuts is disabled in CSE settings."
            }
        }
    }
    
    enum TurnEnum: String, AppEnum {
        case turn
        case toggle
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Operation")
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .turn: "Turn",
            .toggle: "Toggle"
        ]
    }
    
    enum CSESettingsEnum: String, AppEnum {
        case url
        case name
        case post
        case spaceCharacter
        case disablePercentEncoding
        case maxQueryLength
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "CSE Settings")
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .url: "URL",
            .name: "Name",
            .post: "POST Data",
            .spaceCharacter: "Space Character",
            .disablePercentEncoding: "Disable Percent-encoding",
            .maxQueryLength: "Max Query Length"
        ]
    }
}
