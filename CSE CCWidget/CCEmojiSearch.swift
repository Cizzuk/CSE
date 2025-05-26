//
//  CCEmojiSearch.swift
//  CCEmojiSearch
//
//  Created by Cizzuk on 2025/05/26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct CCEmojiSearch: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.tsg0o0.cse.CCWidget.EmojiSearch",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Emoji Search",
                isOn: value,
                action: CCEmojiSearchIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", image: "symbol_EmojiSEIcon")
            }
        }
        .displayName("Emoji Search")
        .description("Turn Emoji Search On or Off on CSE.")
    }
}

extension CCEmojiSearch {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }
        func currentValue() async throws -> Bool {
            return CSEDataManager.userDefaults.bool(forKey: "useEmojiSearch")
        }
    }
}

struct CCEmojiSearchIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Emoji Search"

    @Parameter(title: "Emoji Search", default: false)
    var value: Bool

    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        userDefaults.set(value, forKey: "useEmojiSearch")
        return .result()
    }
}
