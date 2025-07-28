//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

struct DeleteQuickSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "DeleteQuickSE"
    static var title: LocalizedStringResource = "Delete Quick Search Engine"
    static var description: LocalizedStringResource = "Delete a Custom Quick Search Engine with Keyword."
    
    @Parameter(title: "Keyword")
        var cseID: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Delete Quick Search Engine for Keyword \(\.$cseID)")
    }

    func perform() async throws -> some IntentResult {
        CSEDataManager.deleteQuickCSE(cseID)
        return .result()
    }
}
