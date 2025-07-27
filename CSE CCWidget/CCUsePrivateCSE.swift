//
//  CCUsePrivateCSE.swift
//  CCUsePrivateCSE
//
//  Created by Cizzuk on 2025/07/27.
//

import AppIntents
import SwiftUI
import WidgetKit

struct CCUsePrivateCSE: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Private Search Engine",
                isOn: value,
                action: CCUsePrivateCSEIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", image: "symbol_PrivateCSEIcon")
            }
        }
        .displayName("Private Search Engine")
        .description("Turn Private Search Engine On or Off on CSE.")
    }
}

extension CCUsePrivateCSE {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }
        func currentValue() async throws -> Bool {
            return CSEDataManager.userDefaults.bool(forKey: "usePrivateCSE")
        }
    }
}

struct CCUsePrivateCSEIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Private Search Engine"

    @Parameter(title: "Private Search Engine", default: false)
    var value: Bool

    func perform() async throws -> some IntentResult {
        CSEDataManager.userDefaults.set(value, forKey: "usePrivateCSE")
        return .result()
    }
}
