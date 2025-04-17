//
//  EditSEView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/21.
//

import SwiftUI

struct EditSEView: View {
    @Environment(\.dismiss) private var dismiss
    //Load settings
    @Binding var cseType: String
    @Binding var cseID: String
    @Binding var exCSEData: [String: Any]
    @State var CSEData: [String: Any] = [:]
    
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    @State private var cseName: String = ""
    @State private var quickID: String = ""
    @State private var cseURL: String = ""
    @State private var postEntries: [(key: String, value: String)] = []
    @State private var disablePercentEncoding: Bool = false
    @State private var maxQueryLengthToggle: Bool = false
    @State private var maxQueryLengthInput: String? = nil
    @State private var maxQueryLength: Int? = nil

    @State private var showFailAlert: Bool = false
    @State private var showKeyUsedAlert: Bool = false
    @State private var showKeyBlankAlert: Bool = false
    @State private var showURLBlankAlert: Bool = false
    
    @State private var openEditSEViewRecommend: Bool = false
    @State private var isFirstLoad: Bool = true
    
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
            Section {
                // POST Data
                NavigationLink {
                    EditSEViewPostData(postEntries: $postEntries)
                } label: {
                    HStack {
                        Text("POST Data")
                        Spacer()
                        Text("\(postEntries.count)")
                            .foregroundColor(.secondary)
                    }
                }
                // Disable %encode
                Toggle("Disable Percent-encoding", isOn: $disablePercentEncoding)
                // Cut query
                Toggle("Cut Long Query", isOn: $maxQueryLengthToggle)
                if maxQueryLengthToggle {
                    HStack {
                        Text("Max Query Length")
                        Spacer()
                        //Input max query length
                        TextField("32", value: $maxQueryLength, format: .number)
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
        .onAppear {
            if isFirstLoad {
                CSEData = exCSEData
                loadCSEData()
                isFirstLoad = false
            }
            postEntries = postEntries.filter { !$0.key.isEmpty && !$0.value.isEmpty }
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
            .filter { !$0["key"]!.isEmpty && !$0["value"]!.isEmpty }
        
        let fixedMaxQueryLength: Int = maxQueryLengthToggle ? maxQueryLength ?? -1 : -1
        
        // Create temporary data
        var tmpCSEData: [String: Any] = [
            "url": cseURL,
            "disablePercentEncoding": disablePercentEncoding,
            "maxQueryLength": fixedMaxQueryLength,
            "post": postArray
        ]
        
        // Save for Search Engine type
        switch cseType {
        case "default":
            userDefaults.set(tmpCSEData, forKey: "defaultCSE")
        case "private":
            userDefaults.set(tmpCSEData, forKey: "privateCSE")
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
            tmpCSEData["name"] = cseName
            quickCSEData[quickID] = tmpCSEData
            userDefaults.set(quickCSEData, forKey: "quickCSE")
        default: // If unknown CSE type
            showFailAlert = true
            dismiss()
            return
        }
        dismiss()
    }
    
    private func loadCSEData() {
        // Get Data for Search Engine type
        quickID = cseID
        if cseType != "default" && cseType != "private" && cseType != "quick" { // If unknown CSE type
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
            maxQueryLengthToggle = false
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
    }
}

struct EditSEViewPostData: View {
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
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
                        TextField("Value", text: $postEntries[index].value)
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

struct EditSEViewRecommend: View {
    @Binding var isOpenSheet: Bool
    @Binding var CSEData: [String: Any]
    @State private var selectedIndex: Int = -1
    let cseList: [[String: Any]] = recommendCSEList.data
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // Search Engine Selector
                    ForEach(cseList.indices, id: \.self, content: { index in
                        let cse = cseList[index]
                        let cseName = cse["name"] as! String
                        let cseURL = cse["url"] as! String
                        Button {
                            if selectedIndex == index {
                                selectedIndex = -1
                            } else {
                                selectedIndex = index
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(cseName)
                                        .bold()
                                    Text(cseURL)
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                        .accessibilityHidden(true)
                                }
                                Spacer()
                                Image(systemName: selectedIndex == index ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.blue)
                                    .animation(.easeOut(duration: 0.15), value: selectedIndex)
                            }
                        }
                        .accessibilityLabel(cseName)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        CSEData = cseList[selectedIndex]
                        isOpenSheet = false
                    }
                    .disabled(selectedIndex == -1)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
