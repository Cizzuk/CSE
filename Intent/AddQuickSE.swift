//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

struct AddQuickSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "AddQuickSE"
    static var title: LocalizedStringResource = "Add Quick Search Engine"
    static var description: LocalizedStringResource = "Adds a Custom Quick Search Engine on CSE."
    
    @Parameter(title: "Replace", description: "If the keyword is already in use, replace and save", default: false)
        var replace: Bool
    
    @Parameter(title: "Name", default: "")
        var name: String
    
    @Parameter(title: "Keyword", default: "")
        var cseID: String
    
    @Parameter(title: "URL", default: "")
        var cseURL: String
    
    @Parameter(title: "Disable Percent-encoding", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Blank to disable", default: nil)
        var maxQueryLength: Int?

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        let cseData = CSEDataManager.CSEData(
            name: name,
            keyword: cseID,
            url: cseURL,
            disablePercentEncoding: disablePercentEncoding,
            maxQueryLength: maxQueryLength
        )
        
        do {
            try CSEDataManager.saveCSEData(cseData, nil, replace: replace)
        } catch {
            return .result(value: error.localizedDescription)
        }
        
        return .result(value: nil)
    }
}
