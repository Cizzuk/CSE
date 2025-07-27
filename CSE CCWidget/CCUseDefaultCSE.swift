//
//  CCUseDefaultCSE.swift
//  CCUseDefaultCSE
//
//  Created by Cizzuk on 2025/07/27.
//

import AppIntents
import SwiftUI
import WidgetKit

struct CCUseDefaultCSE: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Default Search Engine",
                isOn: value,
                action: CCUseDefaultCSEIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", image: "symbol_CSEIcon")
            }
        }
        .displayName("Default Search Engine")
    }
}

extension CCUseDefaultCSE {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }
        func currentValue() async throws -> Bool {
            return CSEDataManager.userDefaults.bool(forKey: "useDefaultCSE")
        }
    }
}

struct CCUseDefaultCSEIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Default Search Engine"

    @Parameter(title: "Default Search Engine", default: false)
    var value: Bool

    func perform() async throws -> some IntentResult {
        CSEDataManager.userDefaults.set(value, forKey: "useDefaultCSE")
        return .result()
    }
}
