//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI
#if !visionOS
import WidgetKit
#endif

class EditSE {
    
    // Save mode for EditSE
    enum SaveMode {
        case autosave   // Auto save (not upload to iCloud)
        case dismiss    // Save and exit
        case discard    // Discard and save original data
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
                .onSubmit {
                    onSubmit?()
                }
        } header: {
            Text("Search URL")
        } footer: {
            Text("Replace query with %s")
        }
    }
    
    // Common Advanced Settings section
    @ViewBuilder
    static func advancedSettingsSection(cseData: Binding<CSEDataManager.CSEData>, onSubmit: (() -> Void)? = nil) -> some View {
        Section {
            NavigationLink(destination: PostDataView(post: cseData.post)) {
                HStack {
                    Text("POST Data")
                    Spacer()
                    Text("\(cseData.wrappedValue.post.count)")
                        .foregroundColor(.secondary)
                }
            }
            Toggle("Disable Percent-encoding", isOn: cseData.disablePercentEncoding)
                .onChange(of: cseData.wrappedValue.disablePercentEncoding) { _ in
                    onSubmit?()
                }
            HStack {
                Text("Max Query Length")
                Spacer()
                TextField("32", value: cseData.maxQueryLength, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .onSubmit {
                        onSubmit?()
                    }
            }
        } header: {
            Text("Advanced Settings")
        } footer: {
            Text("Blank to disable")
        }
    }
    
    // Common Import Search Engine section
    @ViewBuilder
    static func importSearchEngineSection(
        openRecommendView: Binding<Bool>,
        openCloudImportView: Binding<Bool>
    ) -> some View {
        Section {
            Button(action: {
                openRecommendView.wrappedValue = true
            }) {
                HStack {
                    Image(systemName: "sparkle.magnifyingglass")
                        .frame(width: 20.0)
                        .accessibilityHidden(true)
                    Text("Recommended Search Engines")
                }
            }
            Button(action: {
                openCloudImportView.wrappedValue = true
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
                CloudImportView(isOpenSheet: openCloudImportView, CSEData: cseData)
            }
    }
    
    // DefaultCSE Edit View
    struct EditDefaultCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State private var CSEData = CSEDataManager.CSEData()
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        @State private var isFirstLoad: Bool = true
        
        @AppStorage("useDefaultCSE", store: userDefaults) private var useDefaultCSE: Bool = true
        @State private var useDefaultCSEToggle: Bool = true
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    Section {
                        Toggle(isOn: $useDefaultCSE) {
                            Text("Default Search Engine")
                        }
                        .onChange(of: useDefaultCSE) { _ in
                            withAnimation {
                                useDefaultCSEToggle = useDefaultCSE
                            }
                            #if !visionOS
                            if #available(iOS 18.0, macOS 26, *) {
                                ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
                            }
                            #endif
                        }
                    }
                    
                    if useDefaultCSEToggle {
                        // Search URL
                        EditSE.searchURLSection(cseData: $CSEData) {
                            saveCSEData(.autosave)
                        }
                        
                        // Advanced Settings
                        EditSE.advancedSettingsSection(cseData: $CSEData) {
                            saveCSEData(.autosave)
                        }
                        
                        // Import Search Engine
                        EditSE.importSearchEngineSection(
                            openRecommendView: $openRecommendView,
                            openCloudImportView: $openCloudImportView
                        )
                    }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("Default Search Engine")
                .navigationBarTitleDisplayMode(.inline),
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: {
                    saveCSEData(.autosave)
                }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    saveCSEData(.autosave)
                }
            }
            .onDisappear {
                saveCSEData(.dismiss)
            }
            .task {
                if isFirstLoad {
                    CSEData = CSEDataManager.getCSEData(.defaultCSE)
                    isFirstLoad = false
                } else {
                    saveCSEData(.autosave)
                }
                useDefaultCSEToggle = useDefaultCSE
            }
        }
        
        private func saveCSEData(_ mode: SaveMode) {
            switch mode {
            case .autosave:
                CSEDataManager.saveCSEData(CSEData, .defaultCSE, uploadCloud: false)
            case .dismiss:
                CSEDataManager.saveCSEData(CSEData, .defaultCSE, uploadCloud: true)
            case .discard:
                // No discard action needed for default CSE
                break
            }
        }
    }
    
    // PrivateCSE Edit View
    struct EditPrivateCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State private var CSEData = CSEDataManager.CSEData()
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        @State private var isFirstLoad: Bool = true
        
        @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
        @State private var usePrivateCSEToggle: Bool = false
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    Section {
                        Toggle(isOn: $usePrivateCSE) {
                            Text("Private Search Engine")
                        }
                        .onChange(of: usePrivateCSE) { _ in
                            withAnimation {
                                usePrivateCSEToggle = usePrivateCSE
                            }
                            #if !visionOS
                            if #available(iOS 18.0, macOS 26, *) {
                                ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
                            }
                            #endif
                        }
                    } footer: {
                        Text("Use different search engine in Private Browse")
                    }
                    
                    if usePrivateCSEToggle {
                        // Search URL
                        EditSE.searchURLSection(cseData: $CSEData) {
                            saveCSEData(.autosave)
                        }
                        
                        // Advanced Settings
                        EditSE.advancedSettingsSection(cseData: $CSEData) {
                            saveCSEData(.autosave)
                        }
                        
                        // Import Search Engine
                        EditSE.importSearchEngineSection(
                            openRecommendView: $openRecommendView,
                            openCloudImportView: $openCloudImportView
                        )
                    }
                }
                .scrollToDismissesKeyboard()
                .navigationTitle("Private Search Engine")
                .navigationBarTitleDisplayMode(.inline),
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: {
                    saveCSEData(.autosave)
                }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    saveCSEData(.autosave)
                }
            }
            .onDisappear {
                saveCSEData(.dismiss)
            }
            .task {
                if isFirstLoad {
                    CSEData = CSEDataManager.getCSEData(.privateCSE)
                    isFirstLoad = false
                } else {
                    saveCSEData(.autosave)
                }
                usePrivateCSEToggle = usePrivateCSE
            }
        }
        
        private func saveCSEData(_ mode: SaveMode) {
            switch mode {
            case .autosave:
                CSEDataManager.saveCSEData(CSEData, .privateCSE, uploadCloud: false)
            case .dismiss:
                CSEDataManager.saveCSEData(CSEData, .privateCSE, uploadCloud: true)
            case .discard:
                // No discard action needed for private CSE
                break
            }
        }
    }
    
    // QuickCSE Edit View
    struct EditQuickCSEView: View {
        @Environment(\.dismiss) private var dismiss
        @Environment(\.scenePhase) private var scenePhase
        
        @State var cseID: String? = nil
        @State private var CSEData = CSEDataManager.CSEData()
        @State private var originalCSEData = CSEDataManager.CSEData()
        
        // Alerts
        @State private var showAlert: Bool = false
        @State private var alertTitle: String = String(localized: "An error occurred while loading or updating data")
        
        // Sheets
        @State private var openRecommendView: Bool = false
        @State private var openCloudImportView: Bool = false
        
        @State private var isFirstLoad: Bool = true
        
        var body: some View {
            EditSE.commonSheets(
                List {
                    // Search Engine Name
                    Section {
                        TextField("Name", text: $CSEData.name)
                            .submitLabel(.done)
                            .onSubmit {
                                saveCSEData(.autosave)
                            }
                    } header: {
                        Text("Name")
                    }
                    
                    // Quick Search Key
                    Section {
                        TextField("cse", text: $CSEData.keyword)
                            .submitLabel(.done)
                            .onSubmit {
                                saveCSEData(.autosave)
                            }
                            .onChange(of: CSEData.keyword) { newValue in
                                if newValue.count > 25 {
                                    CSEData.keyword = String(newValue.prefix(25))
                                }
                                CSEData.keyword = CSEData.keyword.filter { !($0.isWhitespace || $0.isNewline) }
                            }
                    } header: {
                        Text("Keyword")
                    } footer: {
                        VStack(alignment : .leading) {
                            Text("Enter this keyword at the top to search with this search engine.")
                            Text("Example: '\(CSEData.keyword == "" ? "cse" : CSEData.keyword) your search'")
                        }
                    }
                    
                    // Search URL
                    EditSE.searchURLSection(cseData: $CSEData) {
                        saveCSEData(.autosave)
                    }
                    
                    // Advanced Settings
                    EditSE.advancedSettingsSection(cseData: $CSEData) {
                        saveCSEData(.autosave)
                    }
                    
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
                        primaryButton: .destructive(Text("Discard")) {
                            dismissView()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .navigationTitle("Quick Search Engine")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu("Back", systemImage: "chevron.backward") {
                            Button(action: {
                                saveCSEData(.dismiss)
                            }) {
                                Label("Save", systemImage: "checkmark")
                            }
                            Button(action: {
                                saveCSEData(.discard)
                            }) {
                                Label("Discard", systemImage: "xmark")
                            }
                        } primaryAction: {
                            saveCSEData(.dismiss)
                        }
                    }
                },
                openRecommendView: $openRecommendView,
                openCloudImportView: $openCloudImportView,
                cseData: $CSEData,
                onDismiss: {
                    saveCSEData(.autosave)
                }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    saveCSEData(.autosave)
                }
            }
            .accessibilityAction(.escape) {
                saveCSEData(.dismiss)
            }
            .task {
                if isFirstLoad {
                    if let cseID = cseID {
                        CSEData = CSEDataManager.getCSEData(.quickCSE, id: cseID)
                    } else {
                        CSEData = CSEDataManager.CSEData()
                    }
                    originalCSEData = CSEData
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
                } catch {
                }
                
            case .dismiss:
                if cseID == nil && CSEData == CSEDataManager.CSEData() {
                    dismissView()
                    return
                }
                saveCSEDataWithErrorHandling(CSEData, targetCSEID: cseID, shouldDismiss: true)
                
            case .discard:
                CSEData = originalCSEData
                saveCSEDataWithErrorHandling(originalCSEData, targetCSEID: cseID, shouldDismiss: true)
            }
        }
        
        private func saveCSEDataWithErrorHandling(_ data: CSEDataManager.CSEData, targetCSEID: String?, shouldDismiss: Bool) {
            let unknownErrorMsg = String(localized: "An error occurred while loading or updating data")
            do {
                try CSEDataManager.saveCSEData(data, targetCSEID)
                if shouldDismiss {
                    dismissView()
                }
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
            .scrollToDismissesKeyboard()
            .navigationTitle("POST Data")
            .navigationBarTitleDisplayMode(.inline)
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
            NavigationStack {
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
        }
    }
    
    // Import from iCloud
    private struct CloudImportView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        
        @State private var isFirstLoad: Bool = true
        @StateObject private var ck = CloudKitManager()
        
        var body: some View {
            NavigationStack {
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
            .interactiveDismissDisabled(ck.isLocked)
        }
    }
    
    private struct ChooseDeviceCSEView: View {
        @Binding var isOpenSheet: Bool
        @Binding var CSEData: CSEDataManager.CSEData
        @Binding var defaultCSE: CSEDataManager.CSEData
        @Binding var privateCSE: CSEDataManager.CSEData
        @Binding var quickCSE: [String: CSEDataManager.CSEData]
        
        @State private var originalID: String?
        
        var body: some View {
            List {
                // Default Search Engine
                if defaultCSE.url != "" {
                    Section {
                        Button {
                            CSEData = defaultCSE
                            CSEData.keyword = originalID ?? defaultCSE.keyword
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
                            CSEData.keyword = originalID ?? privateCSE.keyword
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
            .task {
                originalID = CSEData.keyword
            }
        }
    }
}
