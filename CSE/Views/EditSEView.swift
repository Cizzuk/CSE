//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI
#if !os(visionOS)
import WidgetKit
#endif

struct EditSEView: View {
    @StateObject private var viewModel: EditSEViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("useDefaultCSE", store: userDefaults) private var useDefaultCSE: Bool = true
    @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
    @AppStorage("QuickSearchSettings_keywordPos", store: userDefaults) private var keywordPos: String = QuickSearchKeywordPos.default.rawValue
    
    init(type: CSEDataManager.CSEType, cseID: String? = nil) {
        _viewModel = StateObject(wrappedValue: EditSEViewModel(type: type, cseID: cseID))
    }
    
    var body: some View {
        List {
            // Header / Toggle Section
            headerSection
            
            if isFeatureEnabled {
                // Name & Keyword (QuickCSE only)
                if viewModel.cseType == .quickCSE {
                    quickCSESettingsSection
                }
                
                // Common Settings
                searchURLSection
                advancedSettingsSection
                importSection
            }
        }
        .scrollToDismissesKeyboard()
        .animation(.default, value: isFeatureEnabled)
        .navigationTitle(viewModel.cseType.localizedStringResource)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isShowingAdvancedSettings) {
            AdvancedSettingsView(cseData: $viewModel.cseData, isShowingPostData: $viewModel.isShowingPostData, isOpenSheet: $viewModel.isShowingAdvancedSettings)
                .onDisappear { viewModel.saveData(.autosave) }
        }
        .sheet(isPresented: $viewModel.isShowingPresets) {
            PresetsView(isOpenSheet: $viewModel.isShowingPresets, CSEData: $viewModel.cseData)
                .onDisappear { viewModel.saveData(.autosave) }
        }
        .sheet(isPresented: $viewModel.isShowingCloudImport) {
            CloudPicker.CloudPickerView(cseData: $viewModel.cseData, isOpenSheet: $viewModel.isShowingCloudImport)
                .onDisappear { viewModel.saveData(.autosave) }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text("Are you sure you want to discard changes?"),
                primaryButton: .destructive(Text("Discard")) { dismiss() },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                viewModel.saveData(.autosave)
            }
        }
        .onDisappear {
            if viewModel.cseType != .quickCSE {
                 viewModel.saveData(.dismiss)
            }
        }
        .toolbar {
            if viewModel.cseType == .quickCSE {
                // Override Back Button
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if viewModel.saveData(.dismiss) { dismiss() }
                    }) {
                        Label("Save", systemImage: "checkmark")
                    }
                }
                #if !os(visionOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
                #endif
            }
        }
        .navigationBarBackButtonHidden(viewModel.cseType == .quickCSE)
        .accessibilityAction(.escape) {
            if viewModel.saveData(.dismiss) { dismiss() }
        }
    }
    
    private var isFeatureEnabled: Bool {
        switch viewModel.cseType {
        case .defaultCSE: return useDefaultCSE
        case .privateCSE: return usePrivateCSE
        case .quickCSE: return true
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private var headerSection: some View {
        switch viewModel.cseType {
        case .defaultCSE:
            Section {
                Toggle(isOn: $useDefaultCSE) {
                    UITemplates.IconLabel(icon: "magnifyingglass", text: "Default Search Engine")
                }
                .onChange(of: useDefaultCSE) { newValue in
                    viewModel.handleToggleChange(isOn: newValue, key: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
                }
            }
        case .privateCSE:
            Section {
                Toggle(isOn: $usePrivateCSE) {
                    UITemplates.IconLabel(icon: "hand.raised", text: "Private Search Engine")
                }
                .onChange(of: usePrivateCSE) { newValue in
                    viewModel.handleToggleChange(isOn: newValue, key: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
                }
            } footer: {
                Text("Use different search engine in Private Browse.")
            }
        case .quickCSE:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var quickCSESettingsSection: some View {
        // Search Engine Name
        Section {
            TextField("Name", text: $viewModel.cseData.name)
                .submitLabel(.done)
                .onSubmit { viewModel.saveData(.autosave) }
        } header: { Text("Name") }
        
        // Quick Search Key
        Section {
            TextField("Keyword", text: $viewModel.cseData.keyword, prompt: Text(verbatim: "cse"))
                .submitLabel(.done)
                .onSubmit { viewModel.saveData(.autosave) }
                .onChange(of: viewModel.cseData.keyword) { _ in
                    viewModel.cseData.keyword = viewModel.cseData.keyword.filter { !($0.isWhitespace || $0.isNewline) }
                }
        } header: { Text("Keyword")
        } footer: {
            let enumratedKeywordPos = QuickSearchKeywordPos(rawValue: keywordPos) ?? QuickSearchKeywordPos.default
            let localizedKeywordPos = String(localized: enumratedKeywordPos.displayName)
            Text("Enter this keyword at \(localizedKeywordPos) to search with this search engine.")
        }
    }
    
    @ViewBuilder
    private var searchURLSection: some View {
        Section {
            TextField("URL", text: $viewModel.cseData.url, prompt: Text(verbatim: "https://example.com/search?q=%s"))
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .environment(\.layoutDirection, .leftToRight)
                .submitLabel(.done)
                .onSubmit { viewModel.saveData(.autosave) }
        } header: { Text("Search URL")
        } footer: { Text("Replace query with %s") }
    }
    
    @ViewBuilder
    private var advancedSettingsSection: some View {
        Section {
            Button(action: { viewModel.isShowingAdvancedSettings = true }) {
                HStack {
                    UITemplates.IconLabel(icon: "gearshape.2", text: "Advanced Settings")
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var importSection: some View {
        Section {
            Button(action: { viewModel.isShowingPresets = true }) {
                UITemplates.IconLabel(icon: "sparkle.magnifyingglass", text: "Search Engine Presets")
            }
            Button(action: { viewModel.isShowingCloudImport = true }) {
                UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Import from iCloud")
            }
        }
    }
}

// MARK: - Subviews

private struct AdvancedSettingsView: View {
    @Binding var cseData: CSEDataManager.CSEData
    @Binding var isShowingPostData: Bool
    @Binding var isOpenSheet: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Space Character")
                        Spacer()
                        TextField("Space Character", text: $cseData.spaceCharacter, prompt: Text("+"))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .environment(\.layoutDirection, .leftToRight)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                } footer: {
                    Text("Use a specific character as the query separator. Default is +.")
                }
                
                Section {
                    Toggle("Disable Percent-encoding", isOn: $cseData.disablePercentEncoding)
                } footer: {
                    Text("Disable percent-encoding of queries. When enabled, some symbols and non-ASCII characters may become unavailable.")
                }
                
                Section {
                    HStack {
                        Text("Max Query Length")
                        Spacer()
                        TextField("Max Query Length", value: $cseData.maxQueryLength, format: .number, prompt: Text("32"))
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                } footer: {
                    Text("Truncate the query to the specified character count. Blank to disable.")
                }
                
                Section {
                    Button(action: { isShowingPostData = true }) {
                        HStack {
                            Text("POST Data")
                            Spacer()
                            Text("\(cseData.post.count)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    .contextMenu {
                        Button(role: .destructive) {
                            cseData.post = []
                        } label: {
                            Label("Delete All POST Data", systemImage: "trash")
                        }
                    }
                } footer: {
                    Text("Not Recommended. Search using POST request. Blank to disable.")
                }
            }
            .scrollToDismissesKeyboard()
            .navigationTitle("Advanced Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingPostData) {
                PostDataView(post: $cseData.post, isOpenSheet: $isShowingPostData)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        isOpenSheet = false
                    }
                }
                #if !os(visionOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
                #endif
            }
        }
    }
}

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
                        Text("This feature is not recommended unless the search engine you want to use absolutely requires POST data. It does not improve privacy and may cause unstable behavior.")
                        Spacer()
                        Text("May not work on some operating systems or versions of Safari.")
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
                        .submitLabel(.done)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
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

private struct PresetsView: View {
    @Binding var isOpenSheet: Bool
    @Binding var CSEData: CSEDataManager.CSEData
    
    private let popCSEList = SearchEnginePresets.popCSEList
    private let aiCSEList = SearchEnginePresets.aiCSEList
    private let safariCSEList = SearchEnginePresets.safariCSEList
    
    var body: some View {
        NavigationStack {
            List {
                // Search Engine List
                Section {
                    ForEach(popCSEList.indices, id: \.self, content: { index in
                        let cse = popCSEList[index]
                        UITemplates.PresetSEButton(action: {
                            CSEData = cse
                            isOpenSheet = false
                        }, cse: cse)
                    })
                } header: { Text("Popular Search Engines") }
                
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
