//
//  SetUseQuickSearch.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

struct SetUseQuickSearch: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetUseQuickSearch"
    static var title: LocalizedStringResource = "Set Quick Search"
    static var description: LocalizedStringResource = "Turn Quick Search On or Off on CSE."

    @Parameter(title: "Operation", default: .turn)
        var toggle: IntentTurnEnum?

    @Parameter(title: "State", default: true)
        var state: Bool
    
    static var parameterSummary: some ParameterSummary {
        When(\.$toggle, .equalTo, .turn) {
            Summary("\(\.$toggle) Quick Search \(\.$state)")
        } otherwise: {
            Summary("\(\.$toggle) Quick Search")
        }
    }

    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        var useQuickCSE: Bool = userDefaults.bool(forKey: "useQuickCSE")
        
        switch toggle {
        case .toggle:
            useQuickCSE.toggle()
        case .turn:
            useQuickCSE = state
        default:
            break
        }
        
        userDefaults.set(useQuickCSE, forKey: "useQuickCSE")
        
        return .result()
    }
}
