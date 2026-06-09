//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/12/10.
//

import SwiftUI

struct EditSEView: View {
    @StateObject private var viewModel: EditSEViewSupport
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("useDefaultCSE", store: userDefaults) private var useDefaultCSE: Bool = true
    @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
    @AppStorage("QuickSearchSettings_keywordPos", store: userDefaults) private var keywordPos: String = QuickSearchKeywordPos.default.rawValue
    
    init(type: CSEDataManager.CSEType, cseID: String? = nil) {
        _viewModel = StateObject(wrappedValue: EditSEViewSupport(type: type, cseID: cseID))
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
            AdvSettingsView(cseData: $viewModel.cseData, isShowingPostData: $viewModel.isShowingPostData, isOpenSheet: $viewModel.isShowingAdvancedSettings)
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
                    .keyboardShortcut("S", modifiers: [.command])
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
                        .foregroundStyle(.secondary)
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
