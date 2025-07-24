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
        .glassEffectTutorialButton()
        #endif
}

class Tutorial {
    // First Tutorial
    struct FirstView: View {
        @Binding var isOpenSheet: Bool
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
                    NavigationLink(destination: SafariSEView(isOpenSheet: $isOpenSheet, isFirstTutorial: true)) {
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
    struct SafariSEView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = "google"
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @State private var alsouseprivToggle: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = "duckduckgo"
        
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
                                Toggle(isOn: $alsousepriv.animation()) {
                                    Text("Also Use in Private Browsing")
                                }
                                .onChange(of: alsousepriv) { _ in
                                    withAnimation {
                                        alsouseprivToggle = alsousepriv
                                    }
                                }
                                .onAppear {
                                    alsouseprivToggle = alsousepriv
                                }
                                
                                // Private SE
                                if !alsouseprivToggle {
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
                    
                    NavigationLink(destination: SafariPermissionView(isOpenSheet: $isOpenSheet, isFirstTutorial: isFirstTutorial)) {
                        NextButton(text: NSLocalizedString("Next", comment: ""))
                    }
                    .padding([.horizontal, .bottom], 24)
                }
                #if !visionOS
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                #endif
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private struct SafariPermissionView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = "google"
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = "duckduckgo"
        
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
                        NavigationLink(destination: RecommendView(isOpenSheet: $isOpenSheet)) {
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
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private struct RecommendView: View {
        @Binding var isOpenSheet: Bool
        private let recommendPopCSEList = RecommendSEs.recommendPopCSEList()
        private let recommendAICSEList = RecommendSEs.recommendAICSEList()
        private let recommendNormalCSEList = RecommendSEs.recommendNormalCSEList()
        
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
                            NavigationLink(destination: CloudImportView(isOpenSheet: $isOpenSheet)) {
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
                            ForEach(recommendPopCSEList.indices, id: \.self, content: { index in
                                UITemplates.recommendSEButton(action: {
                                    CSEDataManager.saveCSEData(recommendPopCSEList[index], .defaultCSE)
                                    isOpenSheet = false
                                }, cse: recommendPopCSEList[index])
                            })
                        } header: {
                            Text("Popular Search Engines")
                        }
                        
                        if !recommendAICSEList.isEmpty {
                            Section {
                                ForEach(recommendAICSEList.indices, id: \.self, content: { index in
                                    UITemplates.recommendSEButton(action: {
                                        CSEDataManager.saveCSEData(recommendAICSEList[index], .defaultCSE)
                                        isOpenSheet = false
                                    }, cse: recommendAICSEList[index])
                                })
                            } header: {
                                Text("AI Search Engines")
                            }
                        }
                        
                        Section {
                            ForEach(recommendNormalCSEList.indices, id: \.self, content: { index in
                                UITemplates.recommendSEButton(action: {
                                    CSEDataManager.saveCSEData(recommendNormalCSEList[index], .defaultCSE)
                                    isOpenSheet = false
                                }, cse: recommendNormalCSEList[index])
                            })
                        } header: {
                            Text("Safari Search Engines")
                        }
                        
                    }
                    
                    Button(action: {
                        isOpenSheet = false
                    }) {
                        NextButton(text: NSLocalizedString("Skip", comment: ""))
                    }
                    .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
                }
                #if !visionOS
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                #endif
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private struct CloudImportView: View {
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
                        if selected != nil {
                            // JSON to Dictionary
                            let defaultCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.defaultCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: Any] ?? [:]
                            let privateCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.privateCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: Any] ?? [:]
                            let quickCSE = ck.allCSEs.first(where: { $0.id.recordName == selected })?.quickCSE.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: [String: Any]] ?? [:]
                            
                            let parsedDefaultCSE = CSEDataManager.parseCSEData(defaultCSE)
                            let parsedPrivateCSE = CSEDataManager.parseCSEData(privateCSE)
                            
                            CSEDataManager.saveCSEData(parsedDefaultCSE, .defaultCSE)
                            CSEDataManager.saveCSEData(parsedPrivateCSE, .privateCSE)
                            CSEDataManager.replaceQuickCSEData(quickCSE)
                            
                            userDefaults.set((parsedDefaultCSE.url != ""), forKey: "useDefaultCSE")
                            userDefaults.set((parsedPrivateCSE.url != ""), forKey: "usePrivateCSE")
                            userDefaults.set(!quickCSE.isEmpty, forKey: "useQuickCSE")
                        }
                        isOpenSheet = false
                    }) {
                        if selected == nil {
                            NextButton(text: NSLocalizedString("Skip", comment: ""))
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
            .interactiveDismissDisabled(ck.isLocked)
        }
    }
    
}
