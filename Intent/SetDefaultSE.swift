//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

struct SetDefaultSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetDefaultSE"
    static var title: LocalizedStringResource = "Set Default Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Default Search Engine on CSE."

    @Parameter(title: "URL", default: "")
        var cseURL: String
    
    @Parameter(title: "Disable Percent-encoding", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Blank to disable", default: nil)
        var maxQueryLength: Int?

    func perform() async throws -> some IntentResult {
        let cseData = CSEDataManager.CSEData(
            url: cseURL,
            disablePercentEncoding: disablePercentEncoding,
            maxQueryLength: maxQueryLength
        )
        
        CSEDataManager.saveCSEData(cseData, .defaultCSE)
        
        return .result()
    }
}
