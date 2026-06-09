//
//  TutorialViews+Presets.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI
import UniformTypeIdentifiers

extension TutorialViews {
    struct PresetsView: View {
        @Binding var isOpenSheet: Bool
        @State private var isNavigation: Bool = false
        
        @State private var showingCloudImport = false
        @State private var showingFileImport = false
        @State private var showingErrorAlert = false
        @State private var errorMessage = ""
        private let popCSEList = SearchEnginePresets.popCSEList
        private let noaiCSEList = SearchEnginePresets.noaiCSEList
        private let aiCSEList = SearchEnginePresets.aiCSEList
        private let safariCSEList = SearchEnginePresets.safariCSEList
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Setup Search Engine",
                    description: "Choose a search engine below or customize it later."
                )
                
                Section {
                    Button(action: { showingFileImport = true }) {
                        UITemplates.IconLabel(icon: "square.and.arrow.down", text: "Import from JSON")
                            .foregroundStyle(.accent)
                    }
                    
                    Button(action: { showingCloudImport = true }) {
                        UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Restore from iCloud")
                            .foregroundStyle(.accent)
                    }
                }
                
                if !popCSEList.isEmpty {
                    Section {
                        ForEach(popCSEList.indices, id: \.self, content: { index in
                            UITemplates.PresetSEButton(action: {
                                CSEDataManager.saveCSEData(popCSEList[index], .defaultCSE)
                                isOpenSheet = false
                            }, cse: popCSEList[index])
                        })
                    } header: { Text("Popular Search Engines") }
                }
                
                if !noaiCSEList.isEmpty {
                    Section {
                        ForEach(noaiCSEList.indices, id: \.self, content: { index in
                            UITemplates.PresetSEButton(action: {
                                CSEDataManager.saveCSEData(noaiCSEList[index], .defaultCSE)
                                isOpenSheet = false
                            }, cse: noaiCSEList[index])
                        })
                    } header: { Text("Without AI") }
                }
                
                if !aiCSEList.isEmpty {
                    Section {
                        ForEach(aiCSEList.indices, id: \.self, content: { index in
                            UITemplates.PresetSEButton(action: {
                                CSEDataManager.saveCSEData(aiCSEList[index], .defaultCSE)
                                isOpenSheet = false
                            }, cse: aiCSEList[index])
                        })
                    } header: { Text("AI Assistants") }
                }
                
                if !safariCSEList.isEmpty {
                    Section {
                        ForEach(safariCSEList.indices, id: \.self, content: { index in
                            UITemplates.PresetSEButton(action: {
                                CSEDataManager.saveCSEData(safariCSEList[index], .defaultCSE)
                                isOpenSheet = false
                            }, cse: safariCSEList[index])
                        })
                    } header: { Text("Safari Search Engines") }
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    UITemplates.TutorialButton(action: { isOpenSheet = false }, text: "Skip")
                }
            }
            .sheet(isPresented: $showingCloudImport) {
                CloudPicker.CloudPickerView(onRestore: { isOpenSheet = false })
            }
            .alert(errorMessage, isPresented: $showingErrorAlert, actions: {})
            .fileImporter(
                isPresented: $showingFileImport,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    guard let fileURL = files.first else { return }
                    BackupView.importJSONFile(from: fileURL, onSuccess: {
                        isOpenSheet = false
                    }, onError: { error in
                        errorMessage = error
                        showingErrorAlert = true
                    })
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}
