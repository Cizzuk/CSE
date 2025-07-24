//
//  QuickSEListView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI
#if iOS
import WidgetKit
#endif

struct QuickSEListView: View {
    @State private var quickCSE: [String: CSEDataManager.CSEData] = CSEDataManager.getAllQuickCSEData()
    @AppStorage("useQuickCSE", store: userDefaults) private var useQuickCSE: Bool = false
    @State private var useQuickCSEToggle: Bool = false
    
    var body: some View {
        List {
            // Toggle QuickSE
            Section {
                Toggle(isOn: $useQuickCSE) {
                    Text("Quick Search")
                }
                .onChange(of: useQuickCSE) { _ in
                    withAnimation {
                        useQuickCSEToggle = useQuickCSE
                    }
                    #if iOS
                    if #available(iOS 18.0, *) {
                        ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
                    }
                    #endif
                }
            } footer: {
                Text("Enter the keyword at the top to switch search engines.")
            }
            
            if useQuickCSEToggle {
                // Current Quick SEs List
                Section {
                    let keywordTranslation = NSLocalizedString("Keyword", comment: "")
                    ForEach(quickCSE.keys.sorted(), id: \.self) { cseID in
                        if let cseData: CSEDataManager.CSEData = quickCSE[cseID] {
                            let displayName: String = cseData.name != "" ? cseData.name : cseData.url
                            NavigationLink(destination: EditSE.EditQuickCSEView(cseID: cseID)) {
                                VStack(alignment : .leading) {
                                    Text(cseID)
                                        .bold()
                                    Text(displayName)
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .accessibilityLabel("\(displayName), " + keywordTranslation + ", \(cseID)")
                            .contextMenu {
                                Button() {
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
                    }
                    .onDelete(perform: CSEDataManager.deleteQuickCSE)
                } header: {
                    Text("Quick Search Engines")
                }
                
                // Add new SE Button
                Section {
                    NavigationLink(destination: EditSE.EditQuickCSEView()) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .accessibilityHidden(true)
                            Text("Add New Search Engine")
                        }
                        #if !visionOS
                        .foregroundColor(.accentColor)
                        #endif
                    }
                }
            }
        }
        .navigationTitle("Quick Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .task {
            // Initialize
            quickCSE = CSEDataManager.getAllQuickCSEData()
            useQuickCSEToggle = useQuickCSE
        }
    }
}
