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
    
    // MARK: - Safari SE View 1 Set Safari Settings
    
    struct SafariSEView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @State private var isNavigation: Bool = false
        
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = SafariSEs.default.rawValue
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @State private var alsouseprivToggle: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = SafariSEs.private.rawValue
        
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
                        ForEach(SafariSEs.availableEngines, id: \.self.rawValue) { engine in
                            Text(String(localized: engine.displayName)).tag(engine.rawValue)
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
                                ForEach(SafariSEs.availableEngines, id: \.self.rawValue) { engine in
                                    Text(String(localized: engine.displayName)).tag(engine.rawValue)
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
                        
                        if !SafariSEs.availableEngines.contains(.google) {
                            Spacer()
                            Text("If you set Google as your search engine, please set another search engine.")
                        }
                        
                        // Yandex warning
                        if currentRegion == "UA" || currentRegion == "TR" {
                            Spacer()
                            Text("Yandex is currently unavailable.")
                        }
                    }
                }
                
                // Queries leak warning
                Section {}
                header: {
                    Text("Privacy Tips")
                        .textCase(.none)
                        .padding(.top, 20)
                }
                footer: {
                    VStack(alignment : .leading) {
                        Text("The search engine you select here can see your search queries. If you have privacy concerns, enable \"CSE Content Blocker\" in Safari settings to prevent query leaks. Note that the Content Blocker may disable some features and might not work properly on certain Safari versions.")
                        Spacer()
                        Link("More details on CSE privacy...", destination: URL(string: "https://cizz.uk/cse/privacy-report")!)
                    }
                    .font(.caption)
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
    
    // MARK: - Safari SE View 2 Show Domains
    
    private struct SafariPermissionView: View {
        @Binding var isOpenSheet: Bool
        var isFirstTutorial: Bool = false
        @State private var isNavigation: Bool = false
        
        @AppStorage("searchengine", store: userDefaults) private var searchengine: String = SafariSEs.default.rawValue
        @AppStorage("alsousepriv", store: userDefaults) private var alsousepriv: Bool = true
        @AppStorage("privsearchengine", store: userDefaults) private var privsearchengine: String = SafariSEs.private.rawValue
        
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
                    Text("Open Safari, go to Safari → Settings..., select 'Extensions' tab and enable CSE Extension. Then 'Allow' the following webpage from 'Edit Websites...' button.")
                    #else
                    Text("Go to Settings → Apps → Safari → Extensions → CSE Extension and allow extension. Then 'Allow' the following webpage.")
                    #endif
                }
                
                // Show domains that need to allow
                Section {
                    let selectedSE = SafariSEs(rawValue: searchengine)
                    let selectedPrivateSE = SafariSEs(rawValue: privsearchengine)
                    
                    if let se = selectedSE {
                        ForEach(se.domains, id: \.self) { domain in
                            Text(domain)
                        }
                    }
                    if !alsousepriv, let se = selectedPrivateSE, se != selectedSE {
                        ForEach(se.domains, id: \.self) { domain in
                            Text(domain)
                        }
                    }
                } footer: { Text("And recommended to Deny for Other Websites.") }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isNavigation) {
                PresetsView(isOpenSheet: $isOpenSheet)
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
    
    // MARK: - Presets View
    
    private struct PresetsView: View {
        @Binding var isOpenSheet: Bool
        @State private var isNavigation: Bool = false
        
        @State private var showingCloudImport = false
        @State private var showingFileImport = false
        @State private var showingErrorAlert = false
        @State private var errorMessage = ""
        private let popCSEList = SearchEnginePresets.popCSEList
        private let aiCSEList = SearchEnginePresets.aiCSEList
        private let safariCSEList = SearchEnginePresets.safariCSEList
        
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
                    ForEach(popCSEList.indices, id: \.self, content: { index in
                        UITemplates.PresetSEButton(action: {
                            CSEDataManager.saveCSEData(popCSEList[index], .defaultCSE)
                            isOpenSheet = false
                        }, cse: popCSEList[index])
                    })
                } header: { Text("Popular Search Engines") }
                
                if !aiCSEList.isEmpty {
                    Section {
                        ForEach(aiCSEList.indices, id: \.self, content: { index in
                            UITemplates.PresetSEButton(action: {
                                CSEDataManager.saveCSEData(aiCSEList[index], .defaultCSE)
                                isOpenSheet = false
                            }, cse: aiCSEList[index])
                        })
                    } header: { Text("AI Assistants") }
                }
                
                Section {
                    ForEach(safariCSEList.indices, id: \.self, content: { index in
                        UITemplates.PresetSEButton(action: {
                            CSEDataManager.saveCSEData(safariCSEList[index], .defaultCSE)
                            isOpenSheet = false
                        }, cse: safariCSEList[index])
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
