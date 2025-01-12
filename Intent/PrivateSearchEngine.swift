//
//  PrivateSearchEngine.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 1/12/25.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum PrivateSearchEngineEnum: String, AppEnum {
    case alsousepriv
    case google
    case yahoo
    case bing
    case duckduckgo
    case ecosia
    case baidu
    case sogou
    case so360search
    case yandex

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Engine")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .alsousepriv: "Default Search Engine",
        .google: "Google",
        .yahoo: "Yahoo",
        .bing: "Bing",
        .duckduckgo: "DuckDuckGo",
        .ecosia: "Ecosia",
        .baidu: "Baidu",
        .sogou: "Sogou",
        .so360search: "360 Search",
        .yandex: "Yandex"
    ]
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct PrivateSearchEngine: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "PrivateSearchEngineIntent"

    static var title: LocalizedStringResource = "Set Private Search Engine on CSE"
    static var description = IntentDescription("Sets a Safari Private Search Engine on CSE.")

    @Parameter(title: "Search Engine", default: .duckduckgo)
    var searchEngine: PrivateSearchEngineEnum?

    static var parameterSummary: some ParameterSummary {
        Summary("Set Private Search Engine to \(\.$searchEngine) on CSE")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$searchEngine)) { SearchEngine in
            DisplayRepresentation(
                title: "Set Private Search Engine to \(SearchEngine!) on CSE"
            )
        }
    }

    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
        
        if searchEngine == .alsousepriv {
            userDefaults!.set(true, forKey: "alsousepriv")
        } else {
            userDefaults!.set(false, forKey: "alsousepriv")
            
            let currentRegion = Locale.current.regionCode
            if (currentRegion != "CN" && ["baidu", "sogou", "so360search"].contains(searchEngine?.rawValue))
            || (currentRegion != "RU" && ["yandex"].contains(searchEngine?.rawValue)) {
                userDefaults!.set("duckduckgo", forKey: "privsearchengine")
            } else if searchEngine == .so360search {
                userDefaults!.set("360search", forKey: "privsearchengine")
            } else {
                userDefaults!.set(searchEngine?.rawValue, forKey: "privsearchengine")
            }
        }
        
        return .result()
    }
}
