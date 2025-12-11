//
//  GetQuickCSEList.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/28.
//

import Foundation
import AppIntents

struct GetQuickCSEList: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "GetQuickCSEList"
    static var title: LocalizedStringResource = "Get Quick Search Engine List"
    static var description: LocalizedStringResource = "Gets All Quick Search Engine Keywords"
    
    enum GetCSESettingsError: Error {
        case quickCSENotFound
        case keyBlank
    }

    func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
        let quickCSEs = CSEDataManager.getAllQuickCSEData()
        
        // List up the keywords
        let keywords: [String] = quickCSEs.map { $0.key }.sorted()
        
        return .result(value: keywords)
    }
}
