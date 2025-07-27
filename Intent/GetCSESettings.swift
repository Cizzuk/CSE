//
//  GetCSESettings.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/06/02.
//

import Foundation
import AppIntents

struct GetCSESettings: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "GetCSESettings"
    static var title: LocalizedStringResource = "Get Search Engine Settings"
    static var description: LocalizedStringResource = "Gets the current Custom Search Engine setting."
    
    @Parameter(title: "Search Engine Type", default: .defaultCSE)
        var type: CSEDataManager.CSEType
    
    @Parameter(title: "Keyword", default: "")
        var cseID: String
    
    @Parameter(title: "CSE Settings", default: .url)
        var settings: IntentCSESettingsEnum
    
    static var parameterSummary: some ParameterSummary {
        When(\Self.$type, .equalTo, .quickCSE) {
            Summary("Get \(\.$settings) for \(\.$type) with Keyword \(\.$cseID)")
        } otherwise: {
            Summary("Get \(\.$settings) for \(\.$type)")
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        var cseData: CSEDataManager.CSEData
        
        if type == .quickCSE {
            cseData = CSEDataManager.getCSEData(.quickCSE, id: cseID)
        } else {
            cseData = CSEDataManager.getCSEData(type)
            if type == .privateCSE {
                cseData.name = String(localized: "Private Search Engine")
            } else {
                cseData.name = String(localized: "Default Search Engine")
            }
        }
        
        switch settings {
        case .url:
            return .result(value: cseData.url)
        case .name:
            return .result(value: cseData.name)
        case .disablePercentEncoding:
            return .result(value: cseData.disablePercentEncoding ? "Yes" : "No")
        case .maxQueryLength:
            if let maxQueryLength = cseData.maxQueryLength {
                return .result(value: String(maxQueryLength))
            } else {
                return .result(value: "No")
            }
        }
    }
}
