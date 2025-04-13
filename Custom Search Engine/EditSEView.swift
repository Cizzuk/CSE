//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct EditSEView: View {
    //Load settings
    @Environment(\.dismiss) private var dismiss
    @Binding var cseType: String
    @Binding var cseID: String
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    @State private var cseName: String = ""
    @State private var quickID: String = ""
    @State private var cseURL: String = ""
    @State private var postEntries: [(key: String, value: String)] = []
    @State private var disablePercentEncoding: Bool = false
    @State private var maxQueryLengthToggle: Bool = false
    @State private var maxQueryLength: Int? = nil

    @State private var showFailAlert: Bool = false
    @State private var showKeyUsedAlert: Bool = false
    @State private var showKeyBlankAlert: Bool = false
    @State private var showURLBlankAlert: Bool = false
    
    @State private var showAdvSettings: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var openRecommendSEView: Bool = false
    
    var body: some View {
        NavigationView {
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
                    
                    Section {
                        Button(action: {
                            openRecommendSEView = true
                        }) {
                            HStack {
                                Image(systemName: "sparkle.magnifyingglass")
                                    .frame(width: 20.0)
                                    .accessibilityHidden(true)
                                Text("Recommended Search Engines")
                            }
                        }
                    }
                }
                
                if cseType == "quick" {
                    // Search Engine Name
                    Section {
                        TextField("Name", text: $cseName)
                            .submitLabel(.done)
                    } header: {
                        Text("Name")
                    }
                    // Quick Search Key
                    Section() {
                        TextField("cse", text: $quickID)
                            .submitLabel(.done)
                            .onChange(of: quickID) { newValue in
                                if newValue.count > 25 {
                                    quickID = String(newValue.prefix(25))
                                }
                                quickID = quickID.filter { $0 != " " && $0 != "　" }
                            }
                    } header: {
                        Text("Keyword")
                    } footer: {
                        VStack(alignment : .leading) {
                            Text("Enter this keyword at the top to search with this search engine.")
                            Text("Example: '\(quickID == "" ? "cse" : quickID) your search'")
                        }
                    }
                }
                
                // Search URL
                Section {
                    TextField("", text: $cseURL, prompt: Text(verbatim: "https://example.com/search?q=%s"))
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
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
                if !showAdvSettings {
                    Section {} footer: {
                        Button(action: {
                            showAdvSettings = true
                        }) {
                            HStack {
                                Text("Advanced Settings")
                                Image(systemName: "chevron.down")
                                    .accessibilityHidden(true)
                            }
                        }
                        .textCase(nil)
                        .font(.footnote)
                    }
                }
                
                if showAdvSettings {
                    // POST Data
                    Section {
                        ForEach(postEntries.indices, id: \.self) { index in
                            HStack {
                                TextField("Key", text: $postEntries[index].key)
                                TextField("Value", text: $postEntries[index].value)
                            }
                        }
                        .onDelete {
                            postEntries.remove(atOffsets: $0)
                            if postEntries.count == 0 {
                                editMode = .inactive
                            }
                        }
                        
                        Button(action: {
                            postEntries.append((key: "", value: ""))
                        })  {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .accessibilityHidden(true)
                                Text("Add POST Data")
                            }
                        }
                    } header: {
                        HStack {
                            Text("POST Data")
                            if postEntries.count != 0 {
                                Spacer()
                                Button(action: {
                                    editMode = (editMode == .active) ? .inactive : .active
                                }) {
                                    Text(editMode == .active ? "Done" : "Edit")
                                }
                                .textCase(nil)
                                .font(.footnote)
                            }
                        }
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("Replace query with %s")
                            if userDefaults.bool(forKey: "adv_ignorePOSTFallback") {
                                Text("May not work with some Safari search engines.")
                            }
                        }
                    }
                    
                    // Disable %encode
                    Section {
                        Toggle("Disable Percent-encoding", isOn: $disablePercentEncoding)
                    }
                    
                    // Cut query
                    Section {
                        Toggle("Cut Long Query", isOn: $maxQueryLengthToggle)
                        if maxQueryLengthToggle {
                            HStack {
                                Text("Max Query Length")
                                Spacer()
                                //Input max query length
                                TextField("32", value: $maxQueryLength, formatter: NumberFormatter())
                                    .frame(width: 100)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.done)
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            // Error alerts
            .alert("An error occurred while loading or updating data", isPresented: $showFailAlert, actions:{})
            .alert("This keyword is already used in other", isPresented: $showKeyUsedAlert, actions:{})
            .alert("Keyword cannot be blank", isPresented: $showKeyBlankAlert, actions:{})
            .alert("Search URL cannot be blank", isPresented: $showURLBlankAlert, actions:{})
            .animation(.easeOut(duration: 0.1), value: showAdvSettings)
            .animation(.easeOut(duration: 0.2), value: postEntries.count)
            .animation(.easeOut(duration: 0.2), value: maxQueryLengthToggle)
        }
        .navigationTitle("Edit Search Engine")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveCSEData()
                }
            }
        }
        .sheet(isPresented : $openRecommendSEView , onDismiss: {
            loadCSEData()
        }) {
            RecommendSEView(isOpenSheet: $openRecommendSEView, isFirstTutorial: .constant(false), cseType: $cseType)
        }
        .onAppear {
            loadCSEData()
        }
    }
    
    func saveCSEData() {
        // Normalize Safari search engine URLs
        let replacements = [
            "https://google.com": "https://www.google.com",
            "https://bing.com": "https://www.bing.com",
            "https://www.duckduckgo.com": "https://duckduckgo.com",
            "https://ecosia.com": "https://www.ecosia.com",
            "https://baidu.com": "https://www.baidu.com"
        ]
        for (original, replacement) in replacements {
            if cseURL.hasPrefix(original) {
                cseURL = cseURL.replacingOccurrences(of: original, with: replacement)
                break
            }
        }
        
        // POST Data
        let postArray: [[String: String]] = postEntries
            .map { ["key": $0.key, "value": $0.value] }
            .filter { !$0["key"]!.isEmpty }
            .filter { !$0["value"]!.isEmpty }
        
        let fixedMaxQueryLength: Int = maxQueryLengthToggle ? maxQueryLength ?? -1 : -1
        
        // Create temporary data
        var CSEData: [String: Any] = [
            "url": cseURL,
            "disablePercentEncoding": disablePercentEncoding,
            "maxQueryLength": fixedMaxQueryLength,
            "post": postArray
        ]
        
        // Save for Search Engine type
        switch cseType {
        case "default":
            userDefaults.set(CSEData, forKey: "defaultCSE")
        case "private":
            userDefaults.set(CSEData, forKey: "privateCSE")
        case "quick":
            // If Keyword is blank
            if quickID == "" {
                showKeyBlankAlert = true
                return
            }
            // If URL is blank
            if cseURL == "" {
                showURLBlankAlert = true
                return
            }
            // Get current QuickSEs Data
            var quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
            // If Keyword is changed
            if cseID != quickID {
                // If Keyword is free
                if quickCSEData[quickID] == nil {
                    quickCSEData.removeValue(forKey: cseID)
                    cseID = quickID
                } else {
                    showKeyUsedAlert = true
                    return
                }
            }
            // Replace this QuickSE
            quickCSEData.removeValue(forKey: quickID)
            CSEData["name"] = cseName
            quickCSEData[quickID] = CSEData
            userDefaults.set(quickCSEData, forKey: "quickCSE")
        default: // If unknown CSE type
            showFailAlert = true
            dismiss()
            return
        }
        dismiss()
    }
    
    private func loadCSEData() {
        var CSEData: Dictionary<String, Any>
        // Get Data for Search Engine type
        if cseType == "default" {
            CSEData = userDefaults.dictionary(forKey: "defaultCSE") ?? [:]
        } else if cseType == "private" {
            CSEData = userDefaults.dictionary(forKey: "privateCSE") ?? [:]
        } else if cseType == "quick" {
            let quickCSEData = userDefaults.dictionary(forKey: "quickCSE") ?? [:]
            CSEData = quickCSEData[cseID] as? Dictionary<String, Any> ?? [:]
            quickID = cseID // Get Keyword(=ID)
        } else { // If unknown CSE type
            showFailAlert = true
            dismiss()
            return
        }
        
        // Get Data
        cseName = CSEData["name"] as? String ?? ""
        cseURL = CSEData["url"] as? String ?? ""
        disablePercentEncoding = CSEData["disablePercentEncoding"] as? Bool ?? false
        maxQueryLength = CSEData["maxQueryLength"] as? Int ?? -1
        if maxQueryLength ?? -1 < 0 {
            maxQueryLength = nil
        } else {
            maxQueryLengthToggle = true
        }
        
        // Get POST Data
        // If POST Data exists
        if let postArray = CSEData["post"] as? [[String: String]] {
            postEntries = postArray.compactMap { item in
                if let key = item["key"], let value = item["value"] {
                    return (key: key, value: value)
                } else {
                    return nil
                }
            }
        } else {
            postEntries = []
        }
        
        // Show Advanced Settings
        if postEntries.count > 0 || CSEData["disablePercentEncoding"] as? Bool == true || maxQueryLength != nil {
            showAdvSettings = true
        }
    }
}
