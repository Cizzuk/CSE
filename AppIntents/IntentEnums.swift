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

enum IntentCSESettingsEnum: String, AppEnum {
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
    
