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
    
    @State private var quickCSE: [String: CSEDataManager.CSEData] = CSEDataManager.getAllQuickCSEData()
    @AppStorage("useQuickCSE", store: userDefaults) private var useQuickCSE: Bool = false
    @State private var useQuickCSEToggle: Bool = false
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Toggle QuickSE
                if searchQuery.isEmpty {
                    Section {
                        Toggle(isOn: $useQuickCSE) {
                            UITemplates.IconLabel(icon: "hare", text: "Quick Search")
                        }
                        .onChange(of: useQuickCSE) { _ in
                            withAnimation { useQuickCSEToggle = useQuickCSE }
                            #if !os(visionOS)
                            DispatchQueue.global(qos: .background).async {
                                if #available(iOS 18.0, macOS 26, *) {
                                    ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
                                }
                            }
                            #endif
                        }
                    } footer: { Text("Enter the keyword at the top to switch search engines.") }
                }
                
                if useQuickCSEToggle {
                    if searchQuery.isEmpty {
                        Section {
                            NavigationLink(destination: QuickSearchSettingsView()) {
                                UITemplates.IconLabel(icon: "gearshape", text: "Quick Search Settings")
                            }
                        }
                    }
                    
                    Section {
                        // Add new SE Button
                        if searchQuery.isEmpty {
                            NavigationLink(destination: EditSEView(type: .quickCSE)) {
                                UITemplates.IconLabel(icon: "plus.circle", text: "Add New Search Engine")
                                #if !os(visionOS)
                                .foregroundColor(.accentColor)
                                #endif
                            }
                            .keyboardShortcut("N", modifiers: [.command])
                        }
                        
                        // List of Quick SEs
                        let keywordTranslation = String(localized: "Keyword")
                        let sortedQuick: [(key: String, value: CSEDataManager.CSEData)] = quickCSE
                            .map { ($0.key, $0.value) }
                            .sorted { $0.key < $1.key }
                        
                        ForEach(sortedQuick, id: \.key) { item in
                            let cseID = item.key
                            let cseData = item.value
                            let displayName: String = cseData.name.isEmpty ? cseData.url : cseData.name
                            NavigationLink(destination: EditSEView(type: .quickCSE, cseID: cseID)) {
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
                                NavigationLink(destination: EditSEView(type: .quickCSE)) {
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
                }
            }
            .navigationTitle("Quick Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery)
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
                    searchQuery = ""
                    quickCSE = CSEDataManager.getAllQuickCSEData()
                }
            }
            .onChange(of: searchQuery) { newQuery in
                if newQuery.isEmpty {
                    // Recover Full List
                    quickCSE = CSEDataManager.getAllQuickCSEData()
                } else {
                    // Search QuickCSEs
                    let query = newQuery.lowercased()
                    quickCSE = CSEDataManager.getAllQuickCSEData().filter { key, data in
                        key.lowercased().contains(query) ||
                        data.name.lowercased().contains(query) ||
                        data.url.lowercased().contains(query)
                    }
                }
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
                    }
                }
            }
        }
        .navigationTitle("Quick Search Settings")
    }
}
