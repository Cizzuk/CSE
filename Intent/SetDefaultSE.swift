//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct SetDefaultSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetDefaultSE"
    static var title: LocalizedStringResource = "Set Default Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Default Search Engine on CSE."

    @Parameter(title: "Search Engine URL", default: "")
    var cseURL: String

    static var parameterSummary: some ParameterSummary {
        Summary("Set Default Search Engine to \(\.$cseURL)")
    }

    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        var CSEData: Dictionary<String, Any> = userDefaults.dictionary(forKey: "defaultCSE") ?? [:]
        
        CSEData["url"] = cseURL
        userDefaults.set(CSEData, forKey: "defaultCSE")
        
        return .result()
    }
}
