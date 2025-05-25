//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

fileprivate func HeaderText(text: String) -> some View {
    Text(text)
        .font(.title)
        .fontWeight(.bold)
        .padding(EdgeInsets(top: 32, leading: 32, bottom: 4, trailing: 32))
}

fileprivate func NextButton(text: String) -> some View {
    Text(text)
        .font(.headline)
        .padding()
        #if !visionOS
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(12)
        #endif
}

fileprivate func NextButtonDim(text: String) -> some View {
    Text(text)
        .font(.headline)
        .padding()
        #if !visionOS
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
        #endif
}

// First Tutorial
struct FullTutorialView: View {
    @Binding var isOpenSheet: Bool
    @Binding var isFirstTutorial: Bool
    var body: some View {
        NavigationView {
            VStack() {
                Text("Welcome to CSE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 36, leading: 32, bottom: 8, trailing: 32))
                VStack() {
                    Text("Before you can start using CSE, you need to do some setup.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                List {
                    Section {
                        HStack {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .accessibilityHidden(true)
                                .foregroundColor(.accentColor)
                                .padding(6)
                            Text("Enable Extension in Safari")
                                .font(.headline)
                        }
                        HStack {
                            Image(systemName: "sparkle.magnifyingglass")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .accessibilityHidden(true)
                                .foregroundColor(.accentColor)
                                .padding(6)
                            Text("Setup Custom Search Engine")
                                .font(.headline)
                        }
                        HStack {
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .accessibilityHidden(true)
                                .foregroundColor(.accentColor)
                                .padding(6)
                            Text("Enjoy your Search Life!")
                                .font(.headline)
                        }
                    }
                }
                
                Spacer()
                Button(action: {
                    isOpenSheet = false
                }) {
                    Text("Skip")
                        .bold()
                }
                .padding(.top, 10)
                NavigationLink {
                    SafariTutorialView(isOpenSheet: $isOpenSheet, isFirstTutorial: $isFirstTutorial)
                } label: {
                    NextButton(text: NSLocalizedString("Next", comment: ""))
                }
                .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
            }
            #if !visionOS
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
        .interactiveDismissDisabled()
    }
}

// Set Safari settings
struct SafariTutorialView: View {
    @Binding var isOpenSheet: Bool
    @Binding var isFirstTutorial: Bool
    @AppStorage("searchengine", store: userDefaults)
      private var searchengine: String = userDefaults.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: userDefaults)
      private var alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: userDefaults)
      private var privsearchengine: String = userDefaults.string(forKey: "privsearchengine") ?? "duckduckgo"
    
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Safari Settings", comment: ""))
                VStack() {
                    Text("Please make sure that the following items are the same as your Safari settings")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                    
                List {
                    Section {
                        // Default SE
                        Picker("Search Engine", selection: $searchengine) {
                            if currentRegion == "CN" {
                                Text("Baidu").tag("baidu")
                                Text("Sogou").tag("sogou")
                                Text("360 Search").tag("360search")
                            }
                            if #available(iOS 17.0, macOS 14.0, *) {
                                Text("Google").tag("google")
                            }
                            Text("Yahoo").tag("yahoo")
                            Text("Bing").tag("bing")
                            if currentRegion == "RU" {
                                Text("Yandex").tag("yandex")
                            }
                            Text("DuckDuckGo").tag("duckduckgo")
                            Text("Ecosia").tag("ecosia")
                        }
                        
                        if #available(iOS 17.0, macOS 14.0, *) {
                            Toggle(isOn: $alsousepriv, label: {
                                Text("Also Use in Private Browsing")
                            })
                            
                            // Private SE
                            if !alsousepriv {
                                Picker("Private Search Engine", selection: $privsearchengine) {
                                    if currentRegion == "CN" {
                                        Text("Baidu").tag("baidu")
                                        Text("Sogou").tag("sogou")
                                        Text("360 Search").tag("360search")
                                    }
                                    Text("Google").tag("google")
                                    Text("Yahoo").tag("yahoo")
                                    Text("Bing").tag("bing")
                                    if currentRegion == "RU" {
                                        Text("Yandex").tag("yandex")
                                    }
                                    Text("DuckDuckGo").tag("duckduckgo")
                                    Text("Ecosia").tag("ecosia")
                                }
                            }
                        }
                    } footer: {
                        VStack (alignment : .leading) {
                            #if macOS
                            Text("Open Safari, go to Safari → Settings... and select 'Search' tab to find these settings.")
                            #else
                            Text("You can find these settings in Settings → Apps → Safari.")
                            #endif
                            Spacer()
                            
                            if #unavailable(iOS 17.0, macOS 14.0) {
                                // Show warning if Google is selected in iOS 16 or earlier.
                                Text("If you set Google as your search engine, please set another search engine.")
                            }
                            Spacer()
                            
                            // Show warning if Yandex is selected in Ukraine
                            if currentRegion == "UA" {
                                Text("Yandex is currently unavailable.")
                                Spacer()
                            }
                            
                            // Queries leak warning
                            Text("The search engine you select here can know your search queries. If you have concerns about privacy, I recommend choosing DuckDuckGo.")
                        }
                    }
                }
                .animation(.easeOut(duration: 0.2), value: alsousepriv)
                
                NavigationLink {
                    SafariTutorialSecondView(isOpenSheet: $isOpenSheet, isFirstTutorial: $isFirstTutorial)
                } label: {
                    NextButton(text: NSLocalizedString("Next", comment: ""))
                }
                .padding([.horizontal, .bottom], 24)
            }
            #if !visionOS
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

struct SafariTutorialSecondView: View {
    @Binding var isOpenSheet: Bool
    @Binding var isFirstTutorial: Bool
    @AppStorage("searchengine", store: userDefaults)
      private var searchengine: String = userDefaults.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: userDefaults)
      private var alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: userDefaults)
      private var privsearchengine: String = userDefaults.string(forKey: "privsearchengine") ?? "duckduckgo"
    
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Safari Settings", comment: ""))
                VStack() {
                    Text("Please allow CSE at the following webpage")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                List {
                    Section {} footer: {
                        #if macOS
                        Text("Open Safari, go to Safari → Settings..., select 'Extensions' tab and enable CSE. Then 'Allow' the following webpage from 'Edit Websites...' button.")
                        #else
                        Text("Go to Settings → Apps → Safari → Extensions → Customize Search Engine and allow extension. Then 'Allow' the following webpage.")
                        #endif
                    }
                    
                    // Show domains that need to allow
                    Section {
                        if searchengine == "baidu" || (!alsousepriv && privsearchengine == "baidu") {
                            Text("baidu.com")
                        }
                        if searchengine == "bing" || (!alsousepriv && privsearchengine == "bing") {
                            Text("bing.com")
                        }
                        if searchengine == "duckduckgo" || (!alsousepriv && privsearchengine == "duckduckgo") {
                            Text("duckduckgo.com")
                        }
                        if searchengine == "ecosia" || (!alsousepriv && privsearchengine == "ecosia") {
                            Text("ecosia.org")
                        }
                        if searchengine == "google" || (!alsousepriv && privsearchengine == "google") {
                            if currentRegion == "CN" {
                                Text("google.cn")
                            } else {
                                Text("google.com")
                            }
                        }
                        if searchengine == "yahoo" || (!alsousepriv && privsearchengine == "yahoo") {
                            if currentRegion == "JP" {
                                Text("search.yahoo.co.jp")
                            } else {
                                Text("search.yahoo.com")
                            }
                        }
                        if searchengine == "360search" || (!alsousepriv && privsearchengine == "360search") {
                            Text("so.com")
                        }
                        if searchengine == "sogou" || (!alsousepriv && privsearchengine == "sogou") {
                            Text("sogou.com")
                        }
                        if searchengine == "yandex" || (!alsousepriv && privsearchengine == "yandex") {
                            Text("yandex.ru")
                        }
                    } footer: {
                        Text("And recommended to Deny for Other Websites.")
                    }
                }
                
                if isFirstTutorial {
                    NavigationLink {
                        SafariTutorialRecommendSEView(isOpenSheet: $isOpenSheet)
                    } label: {
                        NextButton(text: NSLocalizedString("Next", comment: ""))
                    }
                    .padding([.horizontal, .bottom], 24)
                } else {
                    Button(action: {
                        isOpenSheet = false
                    }) {
                        NextButton(text: NSLocalizedString("Done", comment: ""))
                    }
                    .padding([.horizontal, .bottom], 24)
                }
            }
            #if !visionOS
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

struct SafariTutorialRecommendSEView: View {
    @Binding var isOpenSheet: Bool
    @State private var selectedIndex: Int = -1
    private let cseList = RecommendSEs.recommendCSEList()
    
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Setup Search Engine", comment: ""))
                VStack() {
                    Text("Choose a search engine below or customize it later.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                List {
                    Section {
                        NavigationLink {
                            SafariTutorialImportView(isOpenSheet: $isOpenSheet)
                        } label: {
                            HStack {
                                Image(systemName: "icloud")
                                    .frame(width: 20.0)
                                    .accessibilityHidden(true)
                                Text("Import from Other Device")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    
                    Section {
                        // Search Engine Selector
                        ForEach(cseList.indices, id: \.self, content: { index in
                            let cse = cseList[index]
                            let cseName = cse.name
                            let cseURL = cse.url
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
                    } header: {
                        Text("Recommended Search Engines")
                    }
                }
                
                Button(action: {
                    if selectedIndex != -1 {
                        CSEDataManager.saveCSEData(cseList[selectedIndex], .defaultCSE)
                    }
                    isOpenSheet = false
                }) {
                    if selectedIndex == -1 {
                        NextButtonDim(text: NSLocalizedString("Skip", comment: ""))
                    } else {
                        NextButton(text: NSLocalizedString("Done", comment: ""))
                    }
                }
                .animation(.easeOut(duration: 0.15), value: selectedIndex)
                .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
            }
            #if !visionOS
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

struct SafariTutorialImportView: View {
    @Binding var isOpenSheet: Bool
    @StateObject private var ck = CloudKitManager()
    @State private var selected: String? = nil
    
    var body: some View {
        NavigationView {
            VStack() {
                List() {
                    if ck.isLoading {
                        ProgressView()
                    } else if ck.error != nil {
                        Text(ck.error!.localizedDescription)
                    } else if ck.allCSEs.isEmpty {
                        Text("No devices found.")
                    } else {
                        ForEach(ck.allCSEs) { ds in
                            Button {
                                if selected == ds.id.recordName {
                                    selected = nil
                                } else {
                                    selected = ds.id.recordName
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ds.deviceName)
                                            .foregroundColor(.primary)
                                        // Modified Time
                                        if let modificationDate: Date = ds.modificationDate {
                                            Text("Last Updated: \(modificationDate.formatted(date: .abbreviated, time: .shortened))")
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: selected == ds.id.recordName ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(.blue)
                                        .animation(.easeOut(duration: 0.15), value: selected)
                                }
                            }
                        }
                    }
                }
                Button(action: {
                    print("Selected: \(selected ?? "nil")")
                    print(ck.allCSEs.first(where: { $0.id.recordName == selected })?.defaultCSE ?? "nil")
                    if selected != nil {
                        // JSON to Dictionary
                        let defaultCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.defaultCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: Any] ?? [:]
                        let privateCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.privateCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: Any] ?? [:]
                        let quickCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.quickCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: [String: Any]] ?? [:]
                        userDefaults.set(defaultCSE, forKey: "defaultCSE")
                        userDefaults.set(privateCSE, forKey: "privateCSE")
                        userDefaults.set(quickCSE, forKey: "quickCSE")
                    }
                    isOpenSheet = false
                }) {
                    if selected == nil {
                        NextButtonDim(text: NSLocalizedString("Skip", comment: ""))
                    } else {
                        NextButton(text: NSLocalizedString("Done", comment: ""))
                    }
                }
                .animation(.easeOut(duration: 0.15), value: selected)
                .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
            }
            #if !visionOS
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
            .task {
                ck.fetchAll()
            }
        }
        .navigationTitle("Choose Device")
        .navigationViewStyle(.stack)
        .interactiveDismissDisabled(ck.isLocked)
    }
}

