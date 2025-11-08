//
//  QuickSEListView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI
#if !os(visionOS)
import WidgetKit
#endif

struct QuickSEListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.editMode) private var editMode
    
    @State private var quickCSE: [String: CSEDataManager.CSEData] = CSEDataManager.getAllQuickCSEData()
    @AppStorage("useQuickCSE", store: userDefaults) private var useQuickCSE: Bool = false
    @State private var useQuickCSEToggle: Bool = false
    
    var body: some View {
        List {
            if editMode?.wrappedValue.isEditing != true {
                // Toggle QuickSE
                Section {
                    Toggle(isOn: $useQuickCSE) {
                        UITemplates.IconLabel(icon: "hare", text: "Quick Search")
                    }
                    .onChange(of: useQuickCSE) { _ in
                        withAnimation { useQuickCSEToggle = useQuickCSE }
                        #if !os(visionOS)
                        if #available(iOS 18.0, macOS 26, *) {
                            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
                        }
                        #endif
                    }
                } footer: { Text("Enter the keyword at the top to switch search engines.") }
            }
            
            if useQuickCSEToggle {
                Section {
                    NavigationLink(destination: QuickSearchSettingsView()) {
                        UITemplates.IconLabel(icon: "gearshape", text: "Quick Search Settings")
                    }
                }
                
                Section {
                    // List of Quick SEs
                    let keywordTranslation = String(localized: "Keyword")
                    let sortedQuick: [(key: String, value: CSEDataManager.CSEData)] = quickCSE
                        .map { ($0.key, $0.value) }
                        .sorted { $0.key < $1.key }
                    
                    ForEach(sortedQuick, id: \.key) { item in
                        let cseID = item.key
                        let cseData = item.value
                        let displayName: String = cseData.name.isEmpty ? cseData.url : cseData.name
                        NavigationLink(destination: EditSE.EditQuickCSEView(cseID: cseID)) {
                            VStack(alignment: .leading) {
                                Text(cseID)
                                    .bold()
                                Text(displayName)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityLabel("\(displayName), " + keywordTranslation + ", \(cseID)")
                        .contextMenu {
                            Button(role: .destructive) {
                                CSEDataManager.deleteQuickCSE(cseID)
                                quickCSE.removeValue(forKey: cseID)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            NavigationLink(destination: EditSE.EditQuickCSEView()) {
                                Label("Add New Search Engine", systemImage: "plus.circle")
                            }
                        }
                    }
                    .onDelete { offsets in
                        let keys = sortedQuick.map { $0.key }
                        for index in offsets {
                            let key = keys[index]
                            CSEDataManager.deleteQuickCSE(key)
                            quickCSE.removeValue(forKey: key)
                        }
                    }
                } header: { Text("Quick Search Engines") }
                
                // Add new SE Button
                if editMode?.wrappedValue.isEditing != true {
                    Section {
                        NavigationLink(destination: EditSE.EditQuickCSEView()) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .accessibilityHidden(true)
                                Text("Add New Search Engine")
                            }
                            #if !os(visionOS)
                            .foregroundColor(.accentColor)
                            #endif
                        }
                    }
                }
            }
        }
        .navigationTitle("Quick Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing == true)
        .toolbar {
            if useQuickCSEToggle { EditButton() }
        }
        .task {
            // Initialize
            quickCSE = CSEDataManager.getAllQuickCSEData()
            useQuickCSEToggle = useQuickCSE
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                quickCSE = CSEDataManager.getAllQuickCSEData()
            }
        }
    }
}

struct QuickSearchSettingsView: View {
    @AppStorage("QuickSearchSettings_keywordOnly", store: userDefaults) private var keywordOnly: Bool = true
    @AppStorage("QuickSearchSettings_keywordPos", store: userDefaults) private var keywordPos: String = QuickSearchKeywordPos.default.rawValue
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $keywordOnly) {
                    Text("Allow Keyword Only Search")
                }
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
                    case .anywhere:
                        Text("Example: 'your cse search'")
                    }
                }
            }
        }
        .navigationTitle("Quick Search Settings")
    }
}
