//
//  QuickSEListView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct QuickSEListView: View {
    @State private var quickCSE: [String: CSEDataManager.CSEData] = CSEDataManager.getAllQuickCSEData()
    
    var body: some View {
        List {
            // Add new SE Button
            Section {
                NavigationLink(destination: EditSEView(cseType: .quickCSE)) {
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
            
            // Current Quick SEs ListdisplayName
            Section {
                let keywordTranslation = NSLocalizedString("Keyword", comment: "")
                ForEach(quickCSE.keys.sorted(), id: \.self) { cseID in
                    if let cseData: CSEDataManager.CSEData = quickCSE[cseID] {
                        let displayName: String = cseData.name != "" ? cseData.name : cseData.url
                        NavigationLink(destination: EditSEView(cseType: .quickCSE, cseID: cseID)) {
                            VStack(alignment : .leading) {
                                Text(cseID)
                                    .bold()
                                Text(displayName)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityLabel("\(displayName). " + keywordTranslation + ". \(cseID)")
                        .contextMenu {
                            Button() {
                                CSEDataManager.deleteQuickCSE(cseID)
                                quickCSE.removeValue(forKey: cseID)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .onDelete(perform: CSEDataManager.deleteQuickCSE)
            }
        }
        .navigationTitle("Quick Search Engines")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .toolbar {
            EditButton()
        }
        .task {
            // Initialize
            quickCSE = CSEDataManager.getAllQuickCSEData()
        }
    }
}
