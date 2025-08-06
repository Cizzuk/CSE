//
//  MainView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/03/13.
//

import SwiftUI

@main
struct MainView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                CloudKitManager().saveAll()
            }
        }
    }
}

struct ContentView: View {
    // Load app settings
    @AppStorage("useDefaultCSE", store: userDefaults) private var useDefaultCSE: Bool = true
    @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
    @AppStorage("useQuickCSE", store: userDefaults) private var useQuickCSE: Bool = false
    @AppStorage("useEmojiSearch", store: userDefaults) private var useEmojiSearch: Bool = false
    
    // Sheets
    @AppStorage("needFirstTutorial", store: userDefaults) private var needFirstTutorial: Bool = true
    @AppStorage("needSafariTutorial", store: userDefaults) private var needSafariTutorial: Bool = false
    @State private var openSafariTutorialView: Bool = false
    
    // Navigation
    @State private var selection: NavigationItem?
    private enum NavigationItem: Hashable {
        case defaultSE, privateSE, quickSE, emojiSearch
        case about, backup, iconChange, advancedSettings
    }
    
    #if !os(visionOS)
    // Get current icon
    @State private var alternateIconName: String? = UIApplication.shared.alternateIconName
    #endif
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List(selection: $selection) {
                // Default SE Settings
                Section {
                    NavigationLink(value: NavigationItem.defaultSE) {
                        HStack {
                            Text("Default Search Engine")
                            Spacer()
                            Text(useDefaultCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Private SE Settings
                    NavigationLink(value: NavigationItem.privateSE) {
                        HStack {
                            Text("Private Search Engine")
                            Spacer()
                            Text(usePrivateCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Quick SE Settings
                    NavigationLink(value: NavigationItem.quickSE) {
                        HStack {
                            Text("Quick Search")
                            Spacer()
                            Text(useQuickCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    
                    // Emoji Search Setting
                    NavigationLink(value: NavigationItem.emojiSearch) {
                        HStack {
                            Text("Emoji Search")
                            Spacer()
                            Text(useEmojiSearch ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                // Show Safari Settings Tutorial Button
                Section {
                    Button(action: {
                        openSafariTutorialView = true
                    }) {
                        VStack(alignment: .leading) {
                            Text("Safari Settings")
                                #if !os(visionOS)
                                .foregroundColor(.accentColor)
                                #endif
                            Text("If you change your Safari settings or CSE does not work properly, you may need to redo this tutorial.")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
//                // IMPORTANT: This code is not currently used, but it is kept here for future reference.
//                #if !os(visionOS) && !targetEnvironment(macCatalyst)
//                // Go IconChange View for iOS/iPadOS
//                Section {
//                    NavigationLink(destination: IconChangeView()) {
//                        Image((alternateIconName ?? "appicon") + "-pre")
//                            .resizable()
//                            .frame(width: 64, height: 64)
//                            .accessibilityHidden(true)
//                            .cornerRadius(14)
//                            .padding(4)
//                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                        Text("Change App Icon")
//                    }
//                }
//                .task {
//                    alternateIconName = UIApplication.shared.alternateIconName
//                }
//                #endif
                
                // Support Section
                Section {
                    Group {
                        // Contact Link
                        Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                            UITemplates.iconButton(icon: "message", text: "Contact")
                        })
                        // GitHub Source Link
                        Link(destination:URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                            UITemplates.iconButton(icon: "ladybug", text: "Source")
                        })
                        // Privacy Policy Link
                        Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                            UITemplates.iconButton(icon: "hand.raised", text: "Privacy Policy")
                        })
                        // About View
                        NavigationLink(value: NavigationItem.about) {
                            UITemplates.iconButton(icon: "info.circle", text: "About")
                        }
                    }
                    #if !os(visionOS)
                    .foregroundColor(.accentColor)
                    #endif
                } header: {
                    Text("Support")
                }
                
                // Advanced Settings
                Section {
                    NavigationLink(value: NavigationItem.backup) {
                        Text("Backup & Restore")
                    }
                    
                    // TODO: Remove this button if CTF issues are resolved. (issue#24)
                    #if !os(visionOS) && !targetEnvironment(macCatalyst)
                    // Go IconChange View for iOS/iPadOS
                    NavigationLink(value: NavigationItem.iconChange) {
                        Text("Change App Icon")
                    }
                    #endif
                    
                    NavigationLink(value: NavigationItem.advancedSettings) {
                        Text("Advanced Settings")
                    }
                }
                
            }
            .navigationTitle("CSE Settings")
            #if os(visionOS)
            .background(.thickMaterial)
            #endif
        } detail: {
            NavigationStack {
                switch selection {
                case .defaultSE:
                    EditSE.EditDefaultCSEView()
                case .privateSE:
                    EditSE.EditPrivateCSEView()
                case .quickSE:
                    QuickSEListView()
                case .emojiSearch:
                    EmojiSearchView()
                case .about:
                    AboutView()
                case .backup:
                    BackupView.BackupView()
                case .iconChange:
                    #if !os(visionOS) && !targetEnvironment(macCatalyst)
                    IconChangeView()
                    #else
                    Spacer()
                    #endif
                case .advancedSettings:
                    AdvSettingView()
                case .none:
                    Spacer()
                }
            }
            #if os(visionOS)
            .background(.ultraThinMaterial)
            #endif
        }
        .navigationSplitViewStyle(.balanced)
        .listStyleFallback()
        // Tutorial sheets
        .sheet(isPresented : $needFirstTutorial, content: {
            Tutorial.FirstView(isOpenSheet: $needFirstTutorial)
        })
        .sheet(isPresented: $needSafariTutorial, content: {
            Tutorial.SafariSEView(isOpenSheet: $needSafariTutorial)
        })
        .sheet(isPresented: $openSafariTutorialView, content: {
            Tutorial.SafariSEView(isOpenSheet: $openSafariTutorialView)
        })
    }
}
