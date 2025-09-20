//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI
#if !os(visionOS)
import WidgetKit
#endif

class EditSE {
    
    // Save mode for EditSE
    enum SaveMode {
        case autosave   // Auto save (not upload to iCloud)
        case dismiss    // Save and exit
    }
    
    // Common search URL section
    @ViewBuilder
    static func searchURLSection(cseData: Binding<CSEDataManager.CSEData>, onSubmit: (() -> Void)? = nil) -> some View {
        Section {
            TextField("", text: cseData.url, prompt: Text(verbatim: "https://example.com/search?q=%s"))
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .environment(\.layoutDirection, .leftToRight)
                .submitLabel(.done)
                .onSubmit { onSubmit?() }
        } header: { Text("Search URL")
        } footer: { Text("Replace query with %s") }
    }
    
    // Common Advanced Settings section
    @ViewBuilder
    static func advancedSettingsSection(cseData: Binding<CSEDataManager.CSEData>, openPostDataView: Binding<Bool>, onSubmit: (() -> Void)? = nil) -> some View {
        Section {
            Button(action: { openPostDataView.wrappedValue = true }) {
                HStack {
                    Text("POST Data")
                    Spacer()
                    Text("\(cseData.wrappedValue.post.count)")
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Toggle("Disable Percent-encoding", isOn: cseData.disablePercentEncoding)
                .onChange(of: cseData.wrappedValue.disablePercentEncoding) { _ in onSubmit?() }
            HStack {
                Text("Max Query Length")
                Spacer()
                TextField("32", value: cseData.maxQueryLength, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .onSubmit { onSubmit?() }
            }
        } header: { Text("Advanced Settings")
        } footer: { Text("Blank to disable") }
    }
    
    // Common Import Search Engine section
    @ViewBuilder
    static func importSearchEngineSection(
        openRecommendView: Binding<Bool>,
        openCloudImportView: Binding<Bool>
    ) -> some View {
        Section {
            Button(action: { openRecommendView.wrappedValue = true }) {
                UITemplates.IconLabel(icon: "sparkle.magnifyingglass", text: "Recommended Search Engines")
            }
            Button(action: { openCloudImportView.wrappedValue = true }) {
                UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Import from iCloud")
            }
        }
    }
    
    // Common sheet settings
    @ViewBuilder
    static func commonSheets<Content: View>(
        _ content: Content,
        openRecommendView: Binding<Bool>,
        openCloudImportView: Binding<Bool>,
        cseData: Binding<CSEDataManager.CSEData>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        content
            .sheet(isPresented: openRecommendView, onDismiss: {
                onDismiss?()
            }) {
                RecommendView(isOpenSheet: openRecommendView, CSEData: cseData)
            }
            .sheet(isPresented: openCloudImportView, onDismiss: {
                onDismiss?()
            }) {
                CloudPicker.CloudPickerView(cseData: cseData, isOpenSheet: openCloudImportView)
            }
    }
    
    // DefaultCSE Edit View
    struct EditDefaultCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State private var CSEData = CSEDataManager.getCSEData(.defaultCSE)
        @State private var tmpCSEData = CSEDataManager.getCSEData(.defaultCSE) // for old OS
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        @State private var openPostDataView: Bool = false
        
        @State private var isFirstLoad: Bool = true
        @State private var lastScenePhase: ScenePhase = .active
        
        @AppStorage("useDefaultCSE", store: userDefaults) private var useDefaultCSE: Bool = true
        @State private var useDefaultCSEToggle: Bool = true
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    Section {
                        Toggle(isOn: $useDefaultCSE) {
                            UITemplates.IconLabel(icon: "magnifyingglass", text: "Default Search Engine")
                        }
                        .onChange(of: useDefaultCSE) { _ in
                            withAnimation { useDefaultCSEToggle = useDefaultCSE }
                            #if !os(visionOS)
                            if #available(iOS 18.0, macOS 26, *) {
                                ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
                            }
                            #endif
                        }
                    }
                    
                    if useDefaultCSEToggle {
                        // Search URL
                        EditSE.searchURLSection(cseData: $CSEData) { saveCSEData(.autosave) }
                        
                        // Advanced Settings
                        EditSE.advancedSettingsSection(cseData: $CSEData, openPostDataView: $openPostDataView) { saveCSEData(.autosave) }
                        
                        // Import Search Engine
                        EditSE.importSearchEngineSection(
                            openRecommendView: $openRecommendView,
                            openCloudImportView: $openCloudImportView
                        )
                    }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("Default Search Engine")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $openPostDataView, onDismiss: {
                    saveCSEData(.autosave)
                }) {
                    PostDataView(post: $CSEData.post, isOpenSheet: $openPostDataView)
                },
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: { saveCSEData(.autosave) }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active && lastScenePhase == .active {
                    saveCSEData(.autosave)
                } else if newPhase == .active {
                    CSEData = CSEDataManager.getCSEData(.defaultCSE)
                    tmpCSEData = CSEData
                }
                lastScenePhase = newPhase
            }
            .onDisappear {
                saveCSEData(.dismiss)
                isFirstLoad = true
            }
            .task {
                if isFirstLoad {
                    CSEData = CSEDataManager.getCSEData(.defaultCSE)
                    tmpCSEData = CSEData
                    isFirstLoad = false
                } else {
                    saveCSEData(.autosave)
                }
                useDefaultCSEToggle = useDefaultCSE
            }
        }
        
        private func saveCSEData(_ mode: SaveMode) {
            if CSEData != tmpCSEData {
                switch mode {
                case .autosave:
                    CSEDataManager.saveCSEData(CSEData, .defaultCSE, uploadCloud: false)
                    tmpCSEData = CSEData
                case .dismiss:
                    CSEDataManager.saveCSEData(CSEData, .defaultCSE, uploadCloud: true)
                    tmpCSEData = CSEData
                }
            }
        }
    }
    
    // PrivateCSE Edit View
    struct EditPrivateCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State private var CSEData = CSEDataManager.getCSEData(.privateCSE)
        @State private var tmpCSEData = CSEDataManager.getCSEData(.privateCSE) // for old OS
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        @State private var openPostDataView: Bool = false
        
        @State private var isFirstLoad: Bool = true
        @State private var lastScenePhase: ScenePhase = .active
        
        @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
        @State private var usePrivateCSEToggle: Bool = false
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    Section {
                        Toggle(isOn: $usePrivateCSE) {
                            UITemplates.IconLabel(icon: "hand.raised", text: "Private Search Engine")
                        }
                        .onChange(of: usePrivateCSE) { _ in
                            withAnimation { usePrivateCSEToggle = usePrivateCSE }
                            #if !os(visionOS)
                            if #available(iOS 18.0, macOS 26, *) {
                                ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
                            }
                            #endif
                        }
                    } footer: {
                        Text("Use different search engine in Private Browse.")
                    }
                    
                    if usePrivateCSEToggle {
                        // Search URL
                        EditSE.searchURLSection(cseData: $CSEData) { saveCSEData(.autosave) }
                        
                        // Advanced Settings
                        EditSE.advancedSettingsSection(cseData: $CSEData, openPostDataView: $openPostDataView) { saveCSEData(.autosave) }
                        
                        // Import Search Engine
                        EditSE.importSearchEngineSection(
                            openRecommendView: $openRecommendView,
                            openCloudImportView: $openCloudImportView
                        )
                    }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("Private Search Engine")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $openPostDataView, onDismiss: {
                    saveCSEData(.autosave)
                }) {
                    PostDataView(post: $CSEData.post, isOpenSheet: $openPostDataView)
                },
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: { saveCSEData(.autosave) }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active && lastScenePhase == .active {
                    saveCSEData(.autosave)
                } else if newPhase == .active {
                    CSEData = CSEDataManager.getCSEData(.privateCSE)
                    tmpCSEData = CSEData
                }
                lastScenePhase = newPhase
            }
            .onDisappear {
                saveCSEData(.dismiss)
                isFirstLoad = true
            }
            .task {
                if isFirstLoad {
                    CSEData = CSEDataManager.getCSEData(.privateCSE)
                    tmpCSEData = CSEData
                    isFirstLoad = false
                } else {
                    saveCSEData(.autosave)
                }
                usePrivateCSEToggle = usePrivateCSE
            }
        }
        
        private func saveCSEData(_ mode: SaveMode) {
            if CSEData != tmpCSEData {
                switch mode {
                case .autosave:
                    CSEDataManager.saveCSEData(CSEData, .privateCSE, uploadCloud: false)
                case .dismiss:
                    CSEDataManager.saveCSEData(CSEData, .privateCSE, uploadCloud: true)
                }
            }
        }
    }
    
    // QuickCSE Edit View
    struct EditQuickCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State var cseID: String? = nil // Original or last saved keyword
        @State private var CSEData = CSEDataManager.CSEData()
        
        // Alerts
        @State private var showAlert: Bool = false
        @State private var alertTitle: String = String(localized: "An error occurred while loading or updating data")
        
        // Sheets
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        @State private var openPostDataView: Bool = false
        
        @State private var isFirstLoad: Bool = true
        @State private var lastScenePhase: ScenePhase = .active
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    // Search Engine Name
                    Section {
                        TextField("Name", text: $CSEData.name)
                            .submitLabel(.done)
                            .onSubmit { saveCSEData(.autosave) }
                    } header: { Text("Name") }
                    
                    // Quick Search Key
                    Section {
                        TextField("cse", text: $CSEData.keyword)
                            .submitLabel(.done)
                            .onSubmit { saveCSEData(.autosave) }
                            .onChange(of: CSEData.keyword) { _ in
                                CSEData.keyword = CSEData.keyword.filter { !($0.isWhitespace || $0.isNewline) }
                            }
                    } header: { Text("Keyword")
                    } footer: {
                        VStack(alignment : .leading) {
                            Text("Enter this keyword at the top to search with this search engine.")
                            Text("Example: '\(CSEData.keyword == "" ? "cse" : CSEData.keyword) your search'")
                        }
                    }
                    
                    // Search URL
                    EditSE.searchURLSection(cseData: $CSEData) { saveCSEData(.autosave) }
                    
                    // Advanced Settings
                    EditSE.advancedSettingsSection(cseData: $CSEData, openPostDataView: $openPostDataView) { saveCSEData(.autosave) }
                    
                    // Import Search Engine
                    EditSE.importSearchEngineSection(
                        openRecommendView: $openRecommendView,
                        openCloudImportView: $openCloudImportView
                    )
                }
                .scrollToDismissesKeyboard()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text("Are you sure you want to discard changes?"),
                        primaryButton: .destructive(Text("Discard")) { dismissView() },
                        secondaryButton: .cancel()
                    )
                }
                .navigationTitle("Quick Search Engine")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu("Back", systemImage: "chevron.backward") {
                            Button(action: { saveCSEData(.dismiss) }) {
                                Label("Save", systemImage: "checkmark")
                            }
                        } primaryAction: { saveCSEData(.dismiss) }
                    }
                }
                .sheet(isPresented: $openPostDataView, onDismiss: {
                    saveCSEData(.autosave)
                }) {
                    PostDataView(post: $CSEData.post, isOpenSheet: $openPostDataView)
                },
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: { saveCSEData(.autosave) }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active && lastScenePhase == .active {
                    saveCSEData(.autosave)
                }
                lastScenePhase = newPhase
            }
            .accessibilityAction(.escape) { saveCSEData(.dismiss) }
            .task {
                if isFirstLoad {
                    if let cseID = cseID {
                        CSEData = CSEDataManager.getCSEData(.quickCSE, id: cseID)
                    } else {
                        CSEData = CSEDataManager.CSEData()
                    }
                    isFirstLoad = false
                } else {
                    saveCSEData(.autosave)
                }
            }
        }
        
        private func saveCSEData(_ mode: SaveMode) {
            switch mode {
            case .autosave:
                do {
                    try CSEDataManager.saveCSEData(CSEData, cseID, uploadCloud: false)
                    cseID = CSEData.keyword
                } catch {}
                
            case .dismiss:
                // If it is from "Add New..." and no changes made, just dismiss without alert
                if cseID == nil && CSEData == CSEDataManager.CSEData() {
                    dismissView()
                    return
                }
                // Otherwise, show alert
                saveCSEDataWithErrorHandling(CSEData, targetCSEID: cseID, shouldDismiss: true)
            }
        }
        
        private func saveCSEDataWithErrorHandling(_ data: CSEDataManager.CSEData, targetCSEID: String?, shouldDismiss: Bool) {
            let unknownErrorMsg = String(localized: "An error occurred while loading or updating data")
            do {
                try CSEDataManager.saveCSEData(data, targetCSEID)
                if shouldDismiss { dismissView() }
            } catch let error as CSEDataManager.saveCSEDataError {
                alertTitle = error.errorDescription ?? unknownErrorMsg
                showAlert = true
            } catch {
                alertTitle = unknownErrorMsg
                showAlert = true
            }
        }
        
        private func dismissView() {
            dismiss()
            isFirstLoad = true
        }
    }
    
    // POST Data Editor
    private struct PostDataView: View {
        @Binding var post: [[String: String]]
        @Binding var isOpenSheet: Bool
        
        var body: some View {
            NavigationStack {
                List {
                    Section {}
                    header: {
                        Text("Not Recommended")
                            .textCase(.none)
                    }
                    footer: {
                        VStack(alignment: .leading) {
                            Text("This feature is not recommended unless the search engine you want to use absolutely requires POST data. It does not improve privacy and may cause unstable behavior")
                            if userDefaults.bool(forKey: "adv_ignorePOSTFallback") {
                                Text("May not work with some Safari search engines.")
                            }
                        }
                    }
                    // POST Data
                    Section {
                        ForEach(post.indices, id: \.self) { index in
                            HStack {
                                TextField("Key", text: binding(for: index, key: "key"))
                                    .environment(\.layoutDirection, .leftToRight)
                                TextField("Value", text: binding(for: index, key: "value"))
                                    .environment(\.layoutDirection, .leftToRight)
                            }
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                        }
                        .onDelete(perform: { index in
                            withAnimation() { post.remove(atOffsets: index) }
                        })
                        
                        Button(action: {
                            withAnimation { post.append(["key": "", "value": ""]) }
                        })  {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .accessibilityHidden(true)
                                Text("Add POST Data")
                            }
                        }
                    } footer: { Text("Replace query with %s") }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("POST Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            isOpenSheet = false
                        }
                    }
                }
            }
        }
        
        private func binding(for index: Int, key: String) -> Binding<String> {
            Binding<String>(
                get: { return post[index][key] ?? "" },
                set: { newValue in post[index][key] = newValue }
            )
        }
    }
    
    // Import Recommended Search Engines
    private struct RecommendView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        
        private let recommendPopCSEList = RecommendSEs.recommendPopCSEList()
        private let recommendAICSEList = RecommendSEs.recommendAICSEList()
        private let recommendNormalCSEList = RecommendSEs.recommendNormalCSEList()
        
        var body: some View {
            NavigationStack {
                List {
                    // Search Engine List
                    Section {
                        ForEach(recommendPopCSEList.indices, id: \.self, content: { index in
                            let cse = recommendPopCSEList[index]
                            UITemplates.RecommendedSEButton(action: {
                                CSEData = cse
                                isOpenSheet = false
                            }, cse: cse)
                        })
                    } header: { Text("Popular Search Engines") }
                    
                    // AI Search Engine List
                    if !recommendAICSEList.isEmpty {
                        Section {
                            ForEach(recommendAICSEList.indices, id: \.self, content: { index in
                                let cse = recommendAICSEList[index]
                                UITemplates.RecommendedSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: { Text("AI Search Engines") }
                    }
                    
                    // Normal Search Engine List
                    Section {
                        ForEach(recommendNormalCSEList.indices, id: \.self, content: { index in
                            let cse = recommendNormalCSEList[index]
                            UITemplates.RecommendedSEButton(action: {
                                CSEData = cse
                                isOpenSheet = false
                            }, cse: cse)
                        })
                    } header: { Text("Safari Search Engines") }
                }
                .navigationTitle("Recommended Search Engines")
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
