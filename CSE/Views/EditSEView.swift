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
        .navigationTitle(viewModel.cseType.localizedStringResource)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isShowingPostData) {
            PostDataView(post: $viewModel.cseData.post, isOpenSheet: $viewModel.isShowingPostData)
                .onDisappear { viewModel.saveData(.autosave) }
        }
        .sheet(isPresented: $viewModel.isShowingRecommend) {
            RecommendView(isOpenSheet: $viewModel.isShowingRecommend, CSEData: $viewModel.cseData)
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
        .onAppear {
            print("EditSEView appeared")
            print(viewModel.cseData.url)
        }
        .onDisappear {
            print("EditSEView disappeared")
            print(viewModel.cseData.url)
            if viewModel.cseType != .quickCSE {
                 viewModel.saveData(.dismiss)
            }
        }
        .toolbar {
            if viewModel.cseType == .quickCSE {
                // Override Back Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Back", systemImage: "chevron.backward") {
                        Button(action: {
                            if viewModel.saveData(.dismiss) { dismiss() }
                        }) {
                            Label("Save", systemImage: "checkmark")
                        }
                    } primaryAction: {
                        if viewModel.saveData(.dismiss) { dismiss() }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(viewModel.cseType == .quickCSE)
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
            Button(action: { viewModel.isShowingPostData = true }) {
                HStack {
                    Text("POST Data")
                    Spacer()
                    Text("\(viewModel.cseData.post.count)")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            .contextMenu {
                Button(role: .destructive) {
                    viewModel.cseData.post = []
                    viewModel.saveData(.autosave)
                } label: {
                    Label("Clear All POST Data", systemImage: "trash")
                }
            }
            
            Toggle("Disable Percent-encoding", isOn: $viewModel.cseData.disablePercentEncoding)
                .onChange(of: viewModel.cseData.disablePercentEncoding) { _ in viewModel.saveData(.autosave) }
            HStack {
                Text("Max Query Length")
                Spacer()
                TextField("Max Query Length", value: $viewModel.cseData.maxQueryLength, format: .number, prompt: Text("32"))
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .onSubmit { viewModel.saveData(.autosave) }
                    #if !os(visionOS)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            } label: {
                                Label("Done", systemImage: "checkmark")
                            }
                        }
                    }
                    #endif
            }
        } header: { Text("Advanced Settings")
        } footer: { Text("Blank to disable") }
    }
    
    @ViewBuilder
    private var importSection: some View {
        Section {
            Button(action: { viewModel.isShowingRecommend = true }) {
                UITemplates.IconLabel(icon: "sparkle.magnifyingglass", text: "Recommended Search Engines")
            }
            Button(action: { viewModel.isShowingCloudImport = true }) {
                UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Import from iCloud")
            }
        }
    }
}

// MARK: - Subviews

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
