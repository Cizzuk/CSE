//
//  QuickSEListView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct QuickSEListView: View {
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    @State var quickCSE: [String: [String: Any]] = [:]
    
    var body: some View {
        List {
            // Add new SE Button
            Section {
                NavigationLink {
                    EditSEView(cseType: .constant("quick"), cseID: .constant(""), exCSEData: .constant([:]))
                } label: {
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
            
            // Current Quick SEs List
            Section {
                ForEach(quickCSE.keys.sorted(), id: \.self) { cseID in
                    if let cseData = quickCSE[cseID],
                        // If cse has no name, use URL instead
                        let cseName = cseData["name"] as? String ?? "" != "" ? cseData["name"] : cseData["url"] {
                        let keywordTranslation = NSLocalizedString("Keyword", comment: "")
                        NavigationLink {
                            EditSEView(cseType: .constant("quick"), cseID: .constant(cseID), exCSEData: .constant(cseData))
                        } label: {
                            VStack(alignment : .leading) {
                                Text(cseID)
                                    .bold()
                                Text(cseName as? String ?? "")
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityLabel("\(cseName as? String ?? ""). " + keywordTranslation + ". \(cseID)")
                    }
                }
                .onDelete(perform: deleteSE)
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
            quickCSE = userDefaults.dictionary(forKey: "quickCSE") as? [String: [String: Any]] ?? [:]
        }
    }
    
    // Delete a Quick Search Engine
    private func deleteSE(at offsets: IndexSet) {
        let keys = quickCSE.keys.sorted()
        for offset in offsets {
            let keyToRemove = keys[offset]
            quickCSE.removeValue(forKey: keyToRemove)
            userDefaults.set(quickCSE, forKey: "quickCSE")
        }
    }
}
