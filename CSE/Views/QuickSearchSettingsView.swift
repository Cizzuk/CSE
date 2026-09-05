//
//  QuickSearchSettingsView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/06/24.
//

import SwiftUI

struct QuickSearchSettingsView: View {
    @AppStorage("QuickSearchSettings_keywordOnly", store: userDefaults) private var keywordOnly: Bool = true
    @AppStorage("QuickSearchSettings_keywordPos", store: userDefaults) private var keywordPos: String = QuickSearchKeywordPos.default.rawValue
    
    var body: some View {
        List {
            Section {
                Toggle("Allow Keyword Only Search", isOn: $keywordOnly)
                    .tint(.accent)
            } footer: {
                Text("CSE will use Quick Search Engines even if you only enter the keyword in the search query.")
            }
            
            Section {
                Picker("Keyword Position", selection: $keywordPos) {
                    ForEach(QuickSearchKeywordPos.allCases, id: \.self.rawValue) { pos in
                        Text(String(localized: pos.displayName)).tag(pos.rawValue)
                    }
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text("Set the position of the keyword in the search query.")
                    switch QuickSearchKeywordPos(rawValue: keywordPos) ?? .default {
                    case .prefix:
                        Text("Example: 'cse your search'")
                    case .suffix:
                        Text("Example: 'your search cse'")
                    case .prefORsuf:
                        Text("Example: 'cse your search' or 'your search cse'")
                    case .prefANDsuf:
                        Text("Example: 'cse your search cse'")
                    }
                }
            }
        }
        .navigationTitle("Quick Search Settings")
    }
}
