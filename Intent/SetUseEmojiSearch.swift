//
//  SetUseQuickSearch.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents
#if iOS
import WidgetKit
#endif

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
        let userDefaults = CSEDataManager.userDefaults
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
        
        #if iOS
        if #available(iOS 18.0, *) {
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.EmojiSearch")
        }
        #endif
        
        return .result()
    }
}
