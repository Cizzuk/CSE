//
//  QuickSEListView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct QuickSEListView: View {
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @State var quickCSE: [String: [String: Any]] = [:]
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    EditSEView(cseType: .constant("quick"), cseID: .constant(""))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .accessibilityHidden(true)
                        Text("Add New Search Engine")
                    }
                    .foregroundColor(.accentColor)
                }
            }
            Section {
                ForEach(quickCSE.keys.sorted(), id: \.self) { cseID in
                    if let cseData = quickCSE[cseID],
                       let cseName = cseData["name"] as? String ?? "" != "" ? cseData["name"] : cseData["url"] {
                        NavigationLink {
                            EditSEView(cseType: .constant("quick"), cseID: .constant(cseID))
                        } label: {
                            VStack(alignment : .leading) {
                                Text(cseID)
                                    .bold()
                                Text(cseName as? String ?? "")
                            }
                        }
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
        .onAppear {
            quickCSE = userDefaults!.dictionary(forKey: "quickCSE") as? [String: [String: Any]] ?? [:]
        }
    }
    
    private func deleteSE(at offsets: IndexSet) {
        let keys = quickCSE.keys.sorted()
        for offset in offsets {
            let keyToRemove = keys[offset]
            quickCSE.removeValue(forKey: keyToRemove)
            userDefaults!.set(quickCSE, forKey: "quickCSE")
        }
    }
}
