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
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    
    @State private var cseName: String = ""
    @State private var quickID: String = ""
    @State private var cseURL: String = ""
    @State private var postEntries: [(key: String, value: String)] = []

    @State private var showFailAlert: Bool = false
    @State private var showKeyUsedAlert: Bool = false
    @State private var showKeyBlankAlert: Bool = false
    @State private var showURLBlankAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                if cseType == "default" {
                    Section {
                        Text("Default Search Engine")
                    }
                } else if cseType == "private" {
                    Section {
                        Text("Private Search Engine")
                    }
                } else if cseType == "quick" {
                    // Search Engine Name
                    Section {
                        TextField("Name", text: $cseName)
                            .submitLabel(.done)
                    } header: {
                        Text("Name")
                    }
                    // Quick Search Key
                    Section() {
                        TextField("q", text: $quickID)
                            .submitLabel(.done)
                    } header: {
                        Text("Quick Search Key")
                    } footer: {
                        VStack(alignment : .leading) {
                            Text("Enter this key first to search with this search engine.")
                            Text("Example: '\(quickID) your search'")
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
                    Text("Replace query with %s")
                }
                
                // POST Data
                Section() {
                    // Display each key-value pair so both can be edited
                    ForEach(postEntries.indices, id: \.self) { index in
                        HStack {
                            TextField("Key", text: $postEntries[index].key)
                            TextField("Value", text: $postEntries[index].value)
                        }
                    }
                    .onDelete {
                        postEntries.remove(atOffsets: $0)
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
                    Text("POST Data")
                } footer: {
                    Text("Replace query with %s")
                }
            }
            .alert("An error occurred while loading or updating data", isPresented: $showFailAlert, actions:{})
            .alert("This Quick Search Key is already in use", isPresented: $showKeyUsedAlert, actions:{})
            .alert("Quick Search Key cannot be blank", isPresented: $showKeyBlankAlert, actions:{})
            .alert("Search URL cannot be blank", isPresented: $showURLBlankAlert, actions:{})
        }
        .navigationTitle("Edit Search Engine")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveCSEData()
                }
            }
        }
        .onAppear {
            loadCSEData()
        }
    }
    
    func saveCSEData() {
        let postArray: [[String: String]] = postEntries.map { ["key": $0.key, "value": $0.value] }
        var CSEData: [String: Any] = [
            "url": cseURL,
            "post": postArray
        ]
        switch cseType {
        case "default":
            userDefaults!.set(CSEData, forKey: "defaultCSE")
        case "private":
            userDefaults!.set(CSEData, forKey: "privateCSE")
        case "quick":
            if quickID == "" {
                showKeyBlankAlert = true
                return
            }
            if cseURL == "" {
                showURLBlankAlert = true
                return
            }
            var quickCSEData = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.dictionary(forKey: "quickCSE") ?? ["":""]
            if cseID != quickID {
                if quickCSEData[quickID] == nil {
                    quickCSEData.removeValue(forKey: cseID)
                    cseID = quickID
                } else {
                    showKeyUsedAlert = true
                    return
                }
            }
            quickCSEData.removeValue(forKey: quickID)
            CSEData["name"] = cseName
            quickCSEData[quickID] = CSEData
            userDefaults!.set(quickCSEData, forKey: "quickCSE")
        default:
            showFailAlert = true
            dismiss()
            return
        }
        dismiss()
    }
    
    private func loadCSEData() {
        var CSEData: Dictionary<String, Any>
        if cseType == "default" {
            CSEData = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.dictionary(forKey: "defaultCSE") ?? [:]
        } else if cseType == "private" {
            CSEData = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.dictionary(forKey: "privateCSE") ?? [:]
        } else if cseType == "quick" {
            let quickCSEData = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.dictionary(forKey: "quickCSE") ?? [:]
            CSEData = quickCSEData[cseID] as? Dictionary<String, Any> ?? [:]
            quickID = cseID
        } else {
            showFailAlert = true
            dismiss()
            return
        }
        
        cseName = CSEData["name"] as? String ?? ""
        cseURL = CSEData["url"] as? String ?? ""
        
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
