//
//  SetPrivateSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SetPrivateSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetPrivateSE"
    static var title: LocalizedStringResource = "Set Private Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Private Search Engine on CSE."

    @Parameter(title: "Search Engine URL", default: "")
    var cseURL: String

    static var parameterSummary: some ParameterSummary {
        Summary("Set Private Search Engine to \(\.$cseURL)")
    }

    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        var CSEData: Dictionary<String, Any> = userDefaults.dictionary(forKey: "privateCSE") ?? [:]
        
        CSEData["url"] = cseURL
        userDefaults.set(CSEData, forKey: "privateCSE")
        
        return .result()
    }
}
