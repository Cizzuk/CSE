//
//  DefaultSearchEngine.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 9/8/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum DefaultSearchEngineEnum: String, AppEnum {
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
struct DefaultSearchEngine: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "DefaultSearchEngineIntent"

    static var title: LocalizedStringResource = "Set Default Search Engine on CSE"
    static var description = IntentDescription("Sets a Safari Default Search Engine on CSE.")

    @Parameter(title: "Search Engine", default: .google)
    var searchEngine: DefaultSearchEngineEnum?

    static var parameterSummary: some ParameterSummary {
        Summary("Set Default Search Engine to \(\.$searchEngine) on CSE")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$searchEngine)) { SearchEngine in
            DisplayRepresentation(
                title: "Set Default Search Engine to \(SearchEngine!) on CSE"
            )
        }
    }

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        
        let currentRegion = Locale.current.regionCode
        if (currentRegion != "CN" && ["baidu", "sogou", "so360search"].contains(searchEngine?.rawValue))
        || (currentRegion != "RU" && ["yandex"].contains(searchEngine?.rawValue)) {
            if currentRegion == "CN" {
                searchEngine = .baidu
            } else {
                searchEngine = .google
            }
        }
        
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
        if searchEngine == .so360search {
            userDefaults!.set("360search", forKey: "searchengine")
        } else {
            userDefaults!.set(searchEngine?.rawValue, forKey: "searchengine")
        }
        
        return .result()
    }
}
