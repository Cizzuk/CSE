//
//  SetUseQuickSearch.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

enum IntentTurnEnum: String, AppEnum {
    case turn
    case toggle

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Operation")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .turn: "Turn",
        .toggle: "Toggle"
    ]
}

enum IntentCSETypeEnum: String, AppEnum {
    case defaultCSE
    case privateCSE
    case quickCSE
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Engine Type")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .defaultCSE: "Default Search Engine",
        .privateCSE: "Private Search Engine",
        .quickCSE: "Quick Search Engine"
    ]
}

enum IntentCSESettingsEnum: String, AppEnum {
    case url
    case name
    case postData
    case disablePercentEncoding
    case maxQueryLength
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "CSE Settings")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .url: "URL",
        .name: "Name",
        .postData: "POST Data",
        .disablePercentEncoding: "Disable Percent-encoding",
        .maxQueryLength: "Max Query Length"
    ]
}
    
