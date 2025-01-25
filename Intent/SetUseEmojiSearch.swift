//
//  SetUseQuickSearch.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SetUseEmojiSearch: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetUseEmojiSearch"
    static var title: LocalizedStringResource = "Set Emoji Search"
    static var description: LocalizedStringResource = "Turn Emoji Search On or Off on CSE."

    @Parameter(title: "Operation", default: .turn)
        var toggle: IntentTurnEnum?

    @Parameter(title: "State", default: true)
        var state: Bool
    
    static var parameterSummary: some ParameterSummary {
        When(\.$toggle, .equalTo, .turn) {
            Summary("\(\.$toggle) Emoji Search \(\.$state)")
        } otherwise: {
            Summary("\(\.$toggle) Emoji Search")
        }
    }

    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        var useEmojiSearch: Bool = userDefaults.bool(forKey: "useEmojiSearch")
        
        switch toggle {
        case .toggle:
            useEmojiSearch.toggle()
        case .turn:
            useEmojiSearch = state
        default:
            break
        }
        
        userDefaults.set(useEmojiSearch, forKey: "useEmojiSearch")
        
        return .result()
    }
}
