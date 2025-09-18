//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI
import UniformTypeIdentifiers

class Tutorial {
    // First Tutorial
    struct FirstView: View {
        @Binding var isOpenSheet: Bool
        @State private var isNavigation: Bool = false
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Welcome to CSE",
                    description: "Before you can start using CSE, you need to do some setup."
                )
                
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
            .navigationDestination(isPresented: $isNavigation) {
                SafariSEView(isOpenSheet: $isOpenSheet, isFirstTutorial: true)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    UITemplates.TutorialButton(action: { isNavigation = true }, text: "Next")
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
            .interactiveDismissDisabled()
        }
    }
    
    // Set Safari settings
    struct SafariSEView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @State private var isNavigation: Bool = false
        
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = "google"
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @State private var alsouseprivToggle: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = "duckduckgo"
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Safari Settings",
                    description: "Please make sure that the following items are the same as your Safari settings"
                )
                
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
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isNavigation) {
                SafariPermissionView(isOpenSheet: $isOpenSheet, isFirstTutorial: isFirstTutorial)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    UITemplates.TutorialButton(action: { isNavigation = true }, text: "Next")
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
    }
    
    private struct SafariPermissionView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @State private var isNavigation: Bool = false
        
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = "google"
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = "duckduckgo"
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Safari Settings",
                    description: "Please allow CSE at the following webpage"
                )
                
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
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isNavigation) {
                RecommendView(isOpenSheet: $isOpenSheet)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if isFirstTutorial {
                        UITemplates.TutorialButton(action: { isNavigation = true }, text: "Next")
                    } else {
                        UITemplates.TutorialButton(action: { isOpenSheet = false }, text: "Done")
                    }
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
    }
    
    private struct RecommendView: View {
        @Binding var isOpenSheet: Bool
        @State private var isNavigation: Bool = false
        
        @State private var showingCloudImport = false
        @State private var showingFileImport = false
        @State private var showingErrorAlert = false
        @State private var errorMessage = ""
        private let recommendPopCSEList = RecommendSEs.recommendPopCSEList()
        private let recommendAICSEList = RecommendSEs.recommendAICSEList()
        private let recommendNormalCSEList = RecommendSEs.recommendNormalCSEList()
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Setup Search Engine",
                    description: "Choose a search engine below or customize it later."
                )
                
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
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    UITemplates.TutorialButton(action: { isOpenSheet = false }, text: "Skip")
                }
            }
            .sheet(isPresented: $showingCloudImport) {
                CloudPicker.CloudPickerView(onRestore: { isOpenSheet = false })
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
