//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

class EditSE {
    struct EditSEView: View {
        @Environment(\.dismiss) private var dismiss
        
        // Load settings
        var cseType: CSEDataManager.CSEType = .defaultCSE // "defaultCSE", "privateCSE", "quickCSE"
        var cseID: String? = nil // If quick search engine, use this ID
        @State private var CSEData = CSEDataManager.CSEData() // Current CSEData
        
        // Alerts
        @State private var showAlert: Bool = false
        @State private var alertTitle: String = ""
        
        // Sheets
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        
        @State private var isFirstLoad: Bool = true // Need to load exCSEData
        
        var body: some View {
            List {
                if cseType == .quickCSE {
                    // Search Engine Name
                    Section {
                        TextField("Name", text: $CSEData.name)
                            .submitLabel(.done)
                    } header: {
                        Text("Name")
                    }
                    // Quick Search Key
                    Section() {
                        TextField("cse", text: $CSEData.keyword)
                            .submitLabel(.done)
                            .onChange(of: CSEData.keyword) { newValue in
                                if newValue.count > 25 {
                                    CSEData.keyword = String(newValue.prefix(25))
                                }
                                CSEData.keyword = CSEData.keyword.filter { $0 != " " && $0 != "　" }
                            }
                    } header: {
                        Text("Keyword")
                    } footer: {
                        VStack(alignment : .leading) {
                            Text("Enter this keyword at the top to search with this search engine.")
                            Text("Example: '\(CSEData.keyword == "" ? "cse" : CSEData.keyword) your search'")
                        }
                    }
                } else {
                    Section {
                        // Search Engine Name
                        if cseType == .defaultCSE {
                            Text("Default Search Engine")
                        } else {
                            Text("Private Search Engine")
                        }
                    }
                }
                
                // Search URL
                Section {
                    TextField("", text: $CSEData.url, prompt: Text(verbatim: "https://example.com/search?q=%s"))
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .environment(\.layoutDirection, .leftToRight)
                        .submitLabel(.done)
                } header: {
                    Text("Search URL")
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Replace query with %s")
                        if cseType == .defaultCSE || cseType == .privateCSE {
                            Text("Blank to disable CSE")
                        }
                    }
                }
                
                // Advanced Settings
                Section {
                    // POST Data
                    NavigationLink(destination: PostDataView(post: $CSEData.post)) {
                        HStack {
                            Text("POST Data")
                            Spacer()
                            Text("\(CSEData.post.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    // Disable %encode
                    Toggle("Disable Percent-encoding", isOn: $CSEData.disablePercentEncoding)
                    HStack {
                        Text("Max Query Length")
                        Spacer()
                        //Input max query length
                        TextField("32", value: $CSEData.maxQueryLength, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                } header: {
                    Text("Advanced Settings")
                } footer: {
                    Text("Blank to disable")
                }
                
                // Import Search Engine
                Section {
                    Button(action: {
                        openRecommendView = true
                    }) {
                        HStack {
                            Image(systemName: "sparkle.magnifyingglass")
                                .frame(width: 20.0)
                                .accessibilityHidden(true)
                            Text("Recommended Search Engines")
                        }
                    }
                    Button(action: {
                        openCloudImportView = true
                    }) {
                        HStack {
                            Image(systemName: "icloud")
                                .frame(width: 20.0)
                                .accessibilityHidden(true)
                            Text("Import from Other Device")
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text("Are you sure you want to discard changes?"),
                    primaryButton: .destructive(Text("Discard")) {
                        dismissView()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("Edit Search Engine")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Back", systemImage: "chevron.backward") {
                        Button(action: {
                            saveCSEData(isDismiss: true)
                        }) {
                            Label("Save", systemImage: "checkmark")
                        }
                        Button(action: {
                            dismissView()
                        }) {
                            Label("Discard", systemImage: "xmark")
                        }
                    } primaryAction: {
                        saveCSEData(isDismiss: true)
                    }
                }
            }
            .sheet(isPresented: $openRecommendView, content: {
                RecommendView(isOpenSheet: $openRecommendView, CSEData: $CSEData)
            })
            .sheet(isPresented: $openCloudImportView, content: {
                CloudImportView(isOpenSheet: $openCloudImportView, CSEData: $CSEData)
            })
            .task {
                // Load existing CSEData
                if isFirstLoad {
                    if cseType == .quickCSE {
                        if let cseID = cseID {
                            CSEData = CSEDataManager.getCSEData(.quickCSE, id: cseID)
                        } else {
                            CSEData = CSEDataManager.CSEData() // Empty CSEData
                        }
                    } else {
                        CSEData = CSEDataManager.getCSEData(cseType)
                    }
                    isFirstLoad = false
                }
            }
        }
        
        private func saveCSEData(isDismiss: Bool = false) {
            if cseType == .quickCSE {
                if isDismiss {
                    if cseID == nil && CSEData == CSEDataManager.CSEData() {
                        dismissView()
                        return
                    }
                    do {
                        try CSEDataManager.saveCSEData(CSEData, cseID)
                    } catch CSEDataManager.saveCSEDataError.keyBlank {
                        alertTitle = NSLocalizedString("Keyword cannot be blank", comment: "")
                        showAlert = true
                        return
                    } catch CSEDataManager.saveCSEDataError.urlBlank {
                        alertTitle = NSLocalizedString("Search URL cannot be blank", comment: "")
                        showAlert = true
                        return
                    } catch CSEDataManager.saveCSEDataError.keyUsed {
                        alertTitle = NSLocalizedString("This keyword is already used in other", comment: "")
                        showAlert = true
                        return
                    } catch {
                        alertTitle = NSLocalizedString("An error occurred while loading or updating data", comment: "")
                        showAlert = true
                        return
                    }
                } else {
                    try? CSEDataManager.saveCSEData(CSEData, cseID)
                }
            } else {
                CSEDataManager.saveCSEData(CSEData, cseType)
            }
            if isDismiss {
                dismissView()
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
        
        var body: some View {
            List {
                Section {} footer: {
                    VStack(alignment: .leading) {
                        Text("This is typically used when a search engine requires an authentication token or special parameters. If not configured correctly, CSE may not work properly.")
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
                        withAnimation() {
                            post.remove(atOffsets: index)
                        }
                    })
                    
                    Button(action: {
                        withAnimation {
                            post.append(["key": "", "value": ""])
                        }
                    })  {
                        HStack {
                            Image(systemName: "plus.circle")
                                .accessibilityHidden(true)
                            Text("Add POST Data")
                        }
                    }
                } footer: {
                    Text("Replace query with %s")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("POST Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                EditButton()
            }
        }
        
        private func binding(for index: Int, key: String) -> Binding<String> {
            Binding<String>(
                get: {
                    return post[index][key] ?? ""
                },
                set: { newValue in
                    post[index][key] = newValue
                }
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
            NavigationView {
                List {
                    // Search Engine List
                    Section {
                        ForEach(recommendPopCSEList.indices, id: \.self, content: { index in
                            let cse = recommendPopCSEList[index]
                            UITemplates.recommendSEButton(action: {
                                CSEData = cse
                                isOpenSheet = false
                            }, cse: cse)
                        })
                    } header: {
                        Text("Popular Search Engines")
                    }
                    // AI Search Engine List
                    if !recommendAICSEList.isEmpty {
                        Section {
                            ForEach(recommendAICSEList.indices, id: \.self, content: { index in
                                let cse = recommendAICSEList[index]
                                UITemplates.recommendSEButton(action: {
                                    CSEData = cse
                                    isOpenSheet = false
                                }, cse: cse)
                            })
                        } header: {
                            Text("AI Search Engines")
                        }
                    }
                    // Normal Search Engine List
                    Section {
                        ForEach(recommendNormalCSEList.indices, id: \.self, content: { index in
                            let cse = recommendNormalCSEList[index]
                            UITemplates.recommendSEButton(action: {
                                CSEData = cse
                                isOpenSheet = false
                            }, cse: cse)
                        })
                    } header: {
                        Text("Safari Search Engines")
                    }
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
            .navigationViewStyle(.stack)
        }
    }
    
    // Import from iCloud
    private struct CloudImportView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        
        @State private var isFirstLoad: Bool = true
        @StateObject private var ck = CloudKitManager()
        
        var body: some View {
            NavigationView {
                List() {
                    if ck.isLoading {
                        ProgressView()
                    } else if ck.error != nil {
                        Text(ck.error!.localizedDescription)
                    } else if ck.allCSEs.isEmpty {
                        Text("No devices found.")
                    } else {
                        ForEach(ck.allCSEs) { ds in
                            NavigationLink {
                                // Load CSEData from CloudKit
                                let dsCSEs = CSEDataManager.parseDeviceCSEs(ds)
                                ChooseDeviceCSEView(
                                    isOpenSheet: $isOpenSheet,
                                    CSEData: $CSEData,
                                    defaultCSE: .constant(dsCSEs.defaultCSE),
                                    privateCSE: .constant(dsCSEs.privateCSE),
                                    quickCSE: .constant(dsCSEs.quickCSE)
                                )
                                .navigationTitle(ds.deviceName)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(ds.deviceName)
                                    // Modified Time
                                    if let modificationDate: Date = ds.modificationDate {
                                        Text("Last Updated: \(modificationDate.formatted(date: .abbreviated, time: .shortened))")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    ck.delete(recordID: ds.id)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                let ds = ck.allCSEs[index]
                                ck.delete(recordID: ds.id)
                            }
                        })
                    }
                }
                .navigationTitle("Choose Device")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        EditButton()
                            .disabled(ck.isLoading || ck.error != nil || ck.allCSEs.isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            isOpenSheet = false
                        }
                        .disabled(ck.isLocked)
                    }
                }
                .task {
                    if isFirstLoad {
                        ck.fetchAll()
                        isFirstLoad = false
                    }
                }
            }
            .navigationViewStyle(.stack)
            .interactiveDismissDisabled(ck.isLocked)
        }
    }
    
    private struct ChooseDeviceCSEView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        @Binding var defaultCSE: CSEDataManager.CSEData
        @Binding var privateCSE: CSEDataManager.CSEData
        @Binding var quickCSE: [String: CSEDataManager.CSEData]
        
        var body: some View {
            List {
                // Default Search Engine
                if defaultCSE.url != "" {
                    Section {
                        Button {
                            CSEData = defaultCSE
                            isOpenSheet = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Default Search Engine")
                                    .bold()
                                    .foregroundColor(.primary)
                                Text(defaultCSE.url)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Private Search Engine
                if privateCSE.url != "" {
                    Section {
                        Button {
                            CSEData = privateCSE
                            isOpenSheet = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Private Search Engine")
                                    .bold()
                                    .foregroundColor(.primary)
                                Text(privateCSE.url)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Quick Search Engines
                if quickCSE.count > 0 {
                    Section {
                        ForEach(quickCSE.keys.sorted(), id: \.self) { cseID in
                            if let cseData = quickCSE[cseID] {
                                let displayName = cseData.name != "" ? cseData.name : cseID
                                Button {
                                    CSEData = cseData
                                    isOpenSheet = false
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(displayName)
                                            .bold()
                                            .foregroundColor(.primary)
                                        Text(cseData.url)
                                            .lineLimit(1)
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Quick Search Engines")
                    }
                }
            }
        }
    }
}
