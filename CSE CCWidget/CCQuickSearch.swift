//
//  CCQuickSearch.swift
//  CCQuickSearch
//
//  Created by Cizzuk on 2025/05/26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct CCQuickSearch: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.tsg0o0.cse.CCWidget.QuickSearch",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Quick Search",
                isOn: value,
                action: CCQuickSearchIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", image: "symbol_QuickCSEIcon")
            }
        }
        .displayName("Quick Search")
        .description("Turn Quick Search On or Off on CSE.")
    }
}

extension CCQuickSearch {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }
        func currentValue() async throws -> Bool {
            return CSEDataManager.userDefaults.bool(forKey: "useQuickCSE")
        }
    }
}

struct CCQuickSearchIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Quick Search"

    @Parameter(title: "Quick Search", default: false)
    var value: Bool

    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        userDefaults.set(value, forKey: "useQuickCSE")
        return .result()
    }
}
