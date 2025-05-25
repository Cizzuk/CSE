//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct EditSEView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Load settings
    @Binding var cseType: String // "default", "private", or "quick"
    @Binding var cseID: String // If quick search engine, use this ID
    @Binding var exCSEData: CSEDataManager.CSEData // Original CSEData
    @State private var CSEData = CSEDataManager.CSEData() // Current CSEData, Changes when import from recommended search engines and iCloud
    
    // CSE settings variables
    @State private var postEntries: [(key: String, value: String)] = []
    @State private var maxQueryLengthToggle: Bool = false

    // Alerts
    @State private var showFailAlert: Bool = false
    @State private var showKeyUsedAlert: Bool = false
    @State private var showKeyBlankAlert: Bool = false
    @State private var showURLBlankAlert: Bool = false
    
    // Sheets
    @State private var openEditSEViewRecommend: Bool = false
    @State private var openEditSEViewCloudImport: Bool = false
    
    @State private var isFirstLoad: Bool = true // Need to load exCSEData
    @State private var isNeedLoad: Bool = false // Need to load CSEData
    
    var body: some View {
        List {
            if cseType == "default" || cseType == "private" {
                Section {
                    // Search Engine Name
                    if cseType == "default" {
                        Text("Default Search Engine")
                    } else {
                        Text("Private Search Engine")
                    }
                }
            }
            
            if cseType == "quick" {
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
                    if cseType == "default" || cseType == "private" {
                        Text("Blank to disable CSE")
                    }
                }
            }
            
            // Advanced Settings
            Section {
                // POST Data
                NavigationLink {
                    EditSEViewPostData(postEntries: $postEntries)
                } label: {
                    HStack {
                        Text("POST Data")
                        Spacer()
                        Text("\(CSEData.post.count)")
                            .foregroundColor(.secondary)
                    }
                }
                // Disable %encode
                Toggle("Disable Percent-encoding", isOn: $CSEData.disablePercentEncoding)
                // Cut query
                Toggle("Cut Long Query", isOn: $maxQueryLengthToggle)
                    .onChange(of: maxQueryLengthToggle) { newValue in
                        if CSEData.maxQueryLength < 0 {
                            CSEData.maxQueryLength = 500 // Default max query length
                        }
                    }
                if maxQueryLengthToggle {
                    HStack {
                        Text("Max Query Length")
                        Spacer()
                        //Input max query length
                        TextField("32", value: $CSEData.maxQueryLength, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                }
            } header: {
                Text("Advanced Settings")
            }
            
            // Import Search Engine
            Section {
                Button(action: {
                    openEditSEViewRecommend = true
                }) {
                    HStack {
                        Image(systemName: "sparkle.magnifyingglass")
                            .frame(width: 20.0)
                            .accessibilityHidden(true)
                        Text("Recommended Search Engines")
                    }
                }
                Button(action: {
                    openEditSEViewCloudImport = true
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
        // Error alerts
        .alert("An error occurred while loading or updating data", isPresented: $showFailAlert, actions:{})
        .alert("This keyword is already used in other", isPresented: $showKeyUsedAlert, actions:{})
        .alert("Keyword cannot be blank", isPresented: $showKeyBlankAlert, actions:{})
        .alert("Search URL cannot be blank", isPresented: $showURLBlankAlert, actions:{})
        .animation(.easeOut(duration: 0.2), value: maxQueryLengthToggle)
        .navigationTitle("Edit Search Engine")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                    isFirstLoad = true
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveCSEData()
                    isFirstLoad = true
                }
            }
        }
        .sheet(isPresented : $openEditSEViewRecommend , onDismiss: {
            loadCSEData()
        }) {
            EditSEViewRecommend(isOpenSheet: $openEditSEViewRecommend, CSEData: $CSEData)
        }
        .sheet(isPresented : $openEditSEViewCloudImport , onDismiss: {
            loadCSEData()
        }) {
            EditSEViewCloudImport(isOpenSheet: $openEditSEViewCloudImport, CSEData: $CSEData)
        }
        .task {
            if isFirstLoad {
                CSEData = exCSEData
                isFirstLoad = false
            }
            loadCSEData()
        }
    }
    
    private func saveCSEData() {
//        // Normalize Safari search engine URLs
//        let replacements = [
//            "https://google.com": "https://www.google.com",
//            "https://bing.com": "https://www.bing.com",
//            "https://www.duckduckgo.com": "https://duckduckgo.com",
//            "https://ecosia.com": "https://www.ecosia.com",
//            "https://baidu.com": "https://www.baidu.com"
//        ]
//        for (original, replacement) in replacements {
//            if cseURL.hasPrefix(original) {
//                cseURL = cseURL.replacingOccurrences(of: original, with: replacement)
//                break
//            }
//        }
//        
//        // POST Data
//        let postArray: [[String: String]] = postEntries
//            .map { ["key": $0.key, "value": $0.value] }
//            .filter { !$0["key"]!.isEmpty && !$0["value"]!.isEmpty }
//        
//        // Check maxQueryLengthToggle is enabled
//        let fixedMaxQueryLength: Int = maxQueryLengthToggle ? maxQueryLength ?? -1 : -1
//        
//        // Create temporary data
//        var tmpCSEData: [String: Any] = [
//            "url": cseURL,
//            "disablePercentEncoding": disablePercentEncoding,
//            "maxQueryLength": fixedMaxQueryLength,
//            "post": postArray
//        ]
//        
//        // Save for Search Engine type
//        switch cseType {
//        case "default":
//            userDefaults.set(tmpCSEData, forKey: "defaultCSE")
//        case "private":
//            userDefaults.set(tmpCSEData, forKey: "privateCSE")
//        case "quick":
//            // If Keyword is blank
//            if quickID == "" {
//                showKeyBlankAlert = true
//                return
//            }
//            // If URL is blank
//            if cseURL == "" {
//                showURLBlankAlert = true
//                return
//            }
//            // Get current QuickSEs Data
//            var quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
//            // If Keyword is changed
//            if cseID != quickID {
//                // If Keyword is free
//                if quickCSEData[quickID] == nil {
//                    quickCSEData.removeValue(forKey: cseID)
//                    cseID = quickID
//                } else {
//                    showKeyUsedAlert = true
//                    return
//                }
//            }
//            // Replace this QuickSE
//            quickCSEData.removeValue(forKey: quickID)
//            tmpCSEData["name"] = cseName
//            quickCSEData[quickID] = tmpCSEData
//            userDefaults.set(quickCSEData, forKey: "quickCSE")
//        default: // If unknown CSE type
//            showFailAlert = true
//            dismiss()
//            return
//        }
//        
//        // Upload CSEData to iCloud
        CloudKitManager().saveAll()
//        
//        dismiss()
    }
    
    private func loadCSEData() {
        postEntries = postEntries.filter { !$0.key.isEmpty && !$0.value.isEmpty }
        maxQueryLengthToggle = CSEData.maxQueryLength >= 0
//        // Get Data for Search Engine type
//        quickID = cseID
//        if cseType != "default" && cseType != "private" && cseType != "quick" { // If unknown CSE type
//            showFailAlert = true
//            dismiss()
//            return
//        }
//        
//        // Get Data
//        cseName = CSEData["name"] as? String ?? ""
//        cseURL = CSEData["url"] as? String ?? ""
//        disablePercentEncoding = CSEData["disablePercentEncoding"] as? Bool ?? false
//        maxQueryLength = CSEData["maxQueryLength"] as? Int ?? -1
//        
//        // Get maxQueryLength
//        if maxQueryLength ?? -1 < 0 {
//            maxQueryLength = nil
//            maxQueryLengthToggle = false
//        } else {
//            maxQueryLengthToggle = true
//        }
//        
//        // Get POST Data
//        // If POST Data exists
//        if let postArray = CSEData["post"] as? [[String: String]] {
//            postEntries = postArray.compactMap { item in
//                if let key = item["key"], let value = item["value"] {
//                    return (key: key, value: value)
//                } else {
//                    return nil
//                }
//            }
//        } else {
//            postEntries = []
//        }
    }
}

// POST Data Editor
struct EditSEViewPostData: View {
    @Binding var postEntries: [(key: String, value: String)]
    
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
                ForEach(postEntries.indices, id: \.self) { index in
                    HStack {
                        TextField("Key", text: $postEntries[index].key)
                            .environment(\.layoutDirection, .leftToRight)
                        TextField("Value", text: $postEntries[index].value)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                }
                .onDelete(perform: { indexSet in
                    postEntries.remove(atOffsets: indexSet)
                })
                
                Button(action: {
                    postEntries.append((key: "", value: ""))
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
        .animation(.easeOut(duration: 0.2), value: postEntries.count)
        .navigationTitle("POST Data")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .toolbar {
            EditButton()
        }
    }
}

// Import Recommended Search Engines
struct EditSEViewRecommend: View {
    @Binding var isOpenSheet: Bool
    @Binding var CSEData: CSEDataManager.CSEData
    private let cseList = recommendCSEList.data
    
    var body: some View {
        NavigationView {
            List {
                // Search Engine List
                Section {
                    ForEach(cseList.indices, id: \.self, content: { index in
                        let cse = cseList[index]
                        Button {
                            CSEData = cseList[index]
                            isOpenSheet = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text(cse.name)
                                    .bold()
                                Text(cse.url)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel(cse.name)
                        .foregroundColor(.primary)
                    })
                }
            }
            .navigationTitle("Recommended Search Engines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpenSheet = false
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Import from iCloud
struct EditSEViewCloudImport: View {
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
                            EditSEViewCloudImportChooseCSE(
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
                    Button("Cancel") {
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

struct EditSEViewCloudImportChooseCSE: View {
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
