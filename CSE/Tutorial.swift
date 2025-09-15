//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate func HeaderText(text: String.LocalizationValue) -> some View {
    Text(String(localized: text))
        .font(.title)
        .fontWeight(.bold)
        .padding(EdgeInsets(top: 32, leading: 32, bottom: 4, trailing: 32))
}

class Tutorial {
    // First Tutorial
    struct FirstView: View {
        @Binding var isOpenSheet: Bool
        var body: some View {
            NavigationStack {
                VStack {
                    Text("Welcome to CSE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 36, leading: 32, bottom: 8, trailing: 32))
                    Text("Before you can start using CSE, you need to do some setup.")
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
                    Button(action: { isOpenSheet = false }) {
                        Text("Skip").bold()
                    }
                    .padding(.top, 10)
                    NavigationLink(destination: SafariSEView(isOpenSheet: $isOpenSheet, isFirstTutorial: true)) {
                        UITemplates.TutorialButton(text: "Next")
                    }
                    .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
                }
                #if !os(visionOS)
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
            NavigationStack {
                VStack {
                    HeaderText(text: "Safari Settings")
                    Text("Please make sure that the following items are the same as your Safari settings")
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                    
                    List {
                        // Open Settings Button
                        UITemplates.OpenSettingsButton()
                        
                        Section {
                            // Default SE
                            Picker("Search Engine", selection: $searchengine) {
                                ForEach(SafariSEs.availableEngines(forRegion: currentRegion), id: \.self.rawValue) { engine in
                                    Text(engine.displayName).tag(engine.rawValue)
                                }
                            }
                            
                            if #available(iOS 17.0, macOS 14.0, *) {
                                Toggle(isOn: $alsousepriv.animation()) {
                                    Text("Also Use in Private Browsing")
                                }
                                .onChange(of: alsousepriv) { _ in
                                    withAnimation { alsouseprivToggle = alsousepriv }
                                }
                                .onAppear { alsouseprivToggle = alsousepriv }
                                
                                // Private SE
                                if !alsouseprivToggle {
                                    Picker("Private Search Engine", selection: $privsearchengine) {
                                        ForEach(SafariSEs.availableEngines(forRegion: currentRegion), id: \.self.rawValue) { engine in
                                            Text(engine.displayName).tag(engine.rawValue)
                                        }
                                    }
                                }
                            }
                        } footer: {
                            VStack (alignment : .leading) {
                                #if targetEnvironment(macCatalyst)
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
                        UITemplates.TutorialButton(text: "Next")
                    }
                    .padding([.horizontal, .bottom], 24)
                }
                #if !os(visionOS)
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
            NavigationStack {
                VStack {
                    HeaderText(text: "Safari Settings")
                    Text("Please allow CSE at the following webpage")
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                    
                    List {
                        Section {
                            // Open Settings Button
                            UITemplates.OpenSettingsButton()
                        } footer: {
                            #if targetEnvironment(macCatalyst)
                            Text("Open Safari, go to Safari → Settings..., select 'Extensions' tab and enable CSE. Then 'Allow' the following webpage from 'Edit Websites...' button.")
                            #else
                            Text("Go to Settings → Apps → Safari → Extensions → Customize Search Engine and allow extension. Then 'Allow' the following webpage.")
                            #endif
                        }
                        
                        // Show domains that need to allow
                        Section {
                            let selectedSE = SafariSEs(rawValue: searchengine)
                            let selectedPrivateSE = SafariSEs(rawValue: privsearchengine)
                            
                            if let se = selectedSE {
                                Text(se.domain(forRegion: currentRegion))
                            }
                            if !alsousepriv, let se = selectedPrivateSE, se != selectedSE {
                                Text(se.domain(forRegion: currentRegion))
                            }
                        } footer: { Text("And recommended to Deny for Other Websites.") }
                    }
                    
                    if isFirstTutorial {
                        NavigationLink(destination: RecommendView(isOpenSheet: $isOpenSheet)) {
                            UITemplates.TutorialButton(text: "Next")
                        }
                        .padding([.horizontal, .bottom], 24)
                    } else {
                        Button(action: { isOpenSheet = false }) {
                            UITemplates.TutorialButton(text: "Done")
                        }
                        .padding([.horizontal, .bottom], 24)
                    }
                }
                #if !os(visionOS)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                #endif
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private struct RecommendView: View {
        @Binding var isOpenSheet: Bool
        @State private var showingCloudImport = false
        @State private var showingFileImport = false
        @State private var showingErrorAlert = false
        @State private var errorMessage = ""
        private let recommendPopCSEList = RecommendSEs.recommendPopCSEList()
        private let recommendAICSEList = RecommendSEs.recommendAICSEList()
        private let recommendNormalCSEList = RecommendSEs.recommendNormalCSEList()
        
        var body: some View {
            NavigationStack {
                VStack {
                    HeaderText(text: "Setup Search Engine")
                    Text("Choose a search engine below or customize it later.")
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                    
                    List {
                        Section {
                            Button(action: { showingFileImport = true }) {
                                UITemplates.IconLabel(icon: "square.and.arrow.down", text: "Import from JSON")
                                .foregroundColor(.accentColor)
                            }
                            
                            Button(action: { showingCloudImport = true }) {
                                UITemplates.IconLabel(icon: "icloud.and.arrow.down", text: "Restore from iCloud")
                                .foregroundColor(.accentColor)
                            }
                        }
                        
                        Section {
                            ForEach(recommendPopCSEList.indices, id: \.self, content: { index in
                                UITemplates.RecommendedSEButton(action: {
                                    CSEDataManager.saveCSEData(recommendPopCSEList[index], .defaultCSE)
                                    isOpenSheet = false
                                }, cse: recommendPopCSEList[index])
                            })
                        } header: { Text("Popular Search Engines") }
                        
                        if !recommendAICSEList.isEmpty {
                            Section {
                                ForEach(recommendAICSEList.indices, id: \.self, content: { index in
                                    UITemplates.RecommendedSEButton(action: {
                                        CSEDataManager.saveCSEData(recommendAICSEList[index], .defaultCSE)
                                        isOpenSheet = false
                                    }, cse: recommendAICSEList[index])
                                })
                            } header: { Text("AI Search Engines") }
                        }
                        
                        Section {
                            ForEach(recommendNormalCSEList.indices, id: \.self, content: { index in
                                UITemplates.RecommendedSEButton(action: {
                                    CSEDataManager.saveCSEData(recommendNormalCSEList[index], .defaultCSE)
                                    isOpenSheet = false
                                }, cse: recommendNormalCSEList[index])
                            })
                        } header: { Text("Safari Search Engines") }
                        
                    }
                    
                    Button(action: { isOpenSheet = false }) {
                        UITemplates.TutorialButton(text: "Skip")
                    }
                    .padding(EdgeInsets(top: 10, leading: 24, bottom: 24, trailing: 24))
                }
                #if !os(visionOS)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                #endif
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingCloudImport) {
                CloudPicker.CloudPickerView(onRestore: {
                    isOpenSheet = false
                })
            }
            .alert(errorMessage, isPresented: $showingErrorAlert, actions: {})
            .fileImporter(
                isPresented: $showingFileImport,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    guard let fileURL = files.first else { return }
                    BackupView.importJSONFile(from: fileURL, onSuccess: {
                        isOpenSheet = false
                    }, onError: { error in
                        errorMessage = error
                        showingErrorAlert = true
                    })
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
}
