//
//  TutorialViews+SafariSettings.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

extension TutorialViews {
    // MARK: - Select Safari SE
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
                    description: "Please configure the settings to match the actual Safari settings."
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
                    VStack(alignment : .leading) {
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
                        Link("More About CSE & Privacy...", destination: URL(string: "https://cizz.uk/cse/privacy-report")!)
                    }
                    .font(.caption)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isNavigation) {
                SafariPermissionView(isOpenSheet: $isOpenSheet, isFirstTutorial: isFirstTutorial)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    UITemplates.TutorialButton(action: { isNavigation = true }, text: "Next")
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
        }
    }
    
    // MARK: - Permission
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
                    description: "Please allow CSE at the following webpage."
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
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
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
}
