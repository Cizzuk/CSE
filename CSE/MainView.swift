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
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List(selection: $selection) {
                // Default SE Settings
                Section {
                    NavigationLink(value: NavigationItem.defaultSE) {
                        HStack {
                            UITemplates.IconLabel(icon: "magnifyingglass", text: "Default Search Engine")
                            Spacer()
                            Text(useDefaultCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Private SE Settings
                    NavigationLink(value: NavigationItem.privateSE) {
                        HStack {
                            UITemplates.IconLabel(icon: "hand.raised", text: "Private Search Engine")
                            Spacer()
                            Text(usePrivateCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Quick SE Settings
                    NavigationLink(value: NavigationItem.quickSE) {
                        HStack {
                            UITemplates.IconLabel(icon: "hare", text: "Quick Search")
                            Spacer()
                            Text(useQuickCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    
                    // Emoji Search Setting
                    NavigationLink(value: NavigationItem.emojiSearch) {
                        HStack {
                            UITemplates.IconLabel(icon: "face.smiling", text: "Emoji Search")
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
                            UITemplates.IconLabel(icon: "safari", text: "Safari Settings")
                                #if !os(visionOS)
                                .foregroundColor(.accentColor)
                                #endif
                            Spacer().frame(height: 4)
                            Text("If you change your Safari settings or CSE does not work properly, you may need to redo this tutorial.")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    // About View
                    NavigationLink(value: NavigationItem.about) {
                        UITemplates.IconLabel(icon: "info.circle", text: "About")
                    }
                    
                    NavigationLink(value: NavigationItem.backup) {
                        UITemplates.IconLabel(icon: "arrow.counterclockwise", text: "Backup & Restore")
                    }
                    
                    // TODO: Remove this button if CTF issues are resolved. (issue#24)
                    #if !os(visionOS) && !targetEnvironment(macCatalyst)
                    // Go IconChange View for iOS/iPadOS
                    NavigationLink(value: NavigationItem.iconChange) {
                        UITemplates.IconLabel(icon: "app.dashed", text: "Change App Icon")
                    }
                    #endif
                    
                    NavigationLink(value: NavigationItem.advancedSettings) {
                        UITemplates.IconLabel(icon: "gearshape", text: "Advanced Settings")
                    }
                }
                
                // Support Section
                Section {
                    Group {
                        // Contact Link
                        Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                            UITemplates.IconLabel(icon: "message", text: "Contact")
                        })
                        // GitHub Source Link
                        Link(destination:URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                            UITemplates.IconLabel(icon: "ladybug", text: "Source")
                        })
                        // App review Link
                        Link(destination:URL(string: "https://apps.apple.com/app/cse/id6445840140")!, label: {
                            UITemplates.IconLabel(icon: "star", text: "Rate & Review")
                        })
                    }
                    #if !os(visionOS)
                    .foregroundColor(.accentColor)
                    #endif
                }
            }
            .navigationTitle("CSE Settings")
            #if os(visionOS)
            .background(.thickMaterial)
            #endif
        } detail: {
            NavigationStack {
                switch selection {
                case .defaultSE: EditSE.EditDefaultCSEView()
                case .privateSE: EditSE.EditPrivateCSEView()
                case .quickSE: QuickSEListView()
                case .emojiSearch: EmojiSearchView()
                case .about: AboutView()
                case .backup: BackupView.BackupView()
                case .iconChange:
                    #if !os(visionOS) && !targetEnvironment(macCatalyst)
                    IconChangeView()
                    #else
                    Spacer()
                    #endif
                case .advancedSettings: AdvSettingView()
                case .none: Spacer()
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
