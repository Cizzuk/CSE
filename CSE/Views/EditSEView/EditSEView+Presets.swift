//
//  EditSEView+Presets.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI

extension EditSEView {
    struct PresetsView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        
        private let popCSEList = SearchEnginePresets.popCSEList
        private let noaiCSEList = SearchEnginePresets.noaiCSEList
        private let aiCSEList = SearchEnginePresets.aiCSEList
        private let safariCSEList = SearchEnginePresets.safariCSEList
        
        var body: some View {
            NavigationStack {
                List {
                    // Search Engine List
                    if !popCSEList.isEmpty {
                        Section {
                            ForEach(popCSEList.indices, id: \.self, content: { index in
                                let cse = popCSEList[index]
                                UITemplates.PresetSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: { Text("Popular Search Engines") }
                    }
                    
                    // Known as No AI Search Engine List
                    if !noaiCSEList.isEmpty {
                        Section {
                            ForEach(noaiCSEList.indices, id: \.self, content: { index in
                                let cse = noaiCSEList[index]
                                UITemplates.PresetSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: { Text("Without AI") }
                    }
                    
                    // AI Search Engine List
                    if !aiCSEList.isEmpty {
                        Section {
                            ForEach(aiCSEList.indices, id: \.self, content: { index in
                                let cse = aiCSEList[index]
                                UITemplates.PresetSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: { Text("AI Assistants") }
                    }
                    
                    // Normal Search Engine List
                    if !safariCSEList.isEmpty {
                        Section {
                            ForEach(safariCSEList.indices, id: \.self, content: { index in
                                let cse = safariCSEList[index]
                                UITemplates.PresetSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: { Text("Safari Search Engines") }
                    }
                }
                .navigationTitle("Search Engine Presets")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            isOpenSheet = false
                        }
                    }
                }
            }
        }
    }
}
