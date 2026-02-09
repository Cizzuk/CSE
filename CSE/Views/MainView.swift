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
                #if targetEnvironment(macCatalyst)
                .onAppear {
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .titlebar?
                        .titleVisibility = .hidden
                }
                #endif
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
    @State private var openSafariTutorialView: Bool = false
    
    // Navigation
    @State private var selection: NavigationItem?
    private enum NavigationItem: String, Hashable {
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
                    Button(action: { openSafariTutorialView = true }) {
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
                    
                    #if !os(visionOS) && !targetEnvironment(macCatalyst)
                    if UIApplication.shared.supportsAlternateIcons {
                        NavigationLink(value: NavigationItem.iconChange) {
                            UITemplates.IconLabel(icon: "app.dashed", text: "Change App Icon")
                        }
                    }
                    #endif
                    
                    NavigationLink(value: NavigationItem.advancedSettings) {
                        UITemplates.IconLabel(icon: "gearshape.2", text: "Advanced Settings")
                    }
                }
            }
            .navigationTitle("CSE Settings")
            #if os(visionOS)
            .background(.thickMaterial)
            #endif
        } detail: {
            switch selection {
            case .defaultSE: EditSEView(type: .defaultCSE)
            case .privateSE: EditSEView(type: .privateCSE)
            case .quickSE: QuickSEListView()
            case .emojiSearch: EmojiSearchView()
            case .about: AboutView()
            case .backup: BackupView.BackupView()
            case .iconChange:
                #if !os(visionOS) && !targetEnvironment(macCatalyst)
                IconChangeView()
                #else
                EmptyView()
                #endif
            case .advancedSettings: AdvSettingView()
            case .none: EmptyView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .listStyleFallback()
        // Tutorial sheets
        .sheet(isPresented : $needFirstTutorial) {
            NavigationStack {
                Tutorial.FirstView(isOpenSheet: $needFirstTutorial)
            }
        }
        .sheet(isPresented: $openSafariTutorialView) {
            NavigationStack {
                Tutorial.SafariSEView(isOpenSheet: $openSafariTutorialView)
            }
        }
        .onOpenURL { url in
            // Handle URL Scheme
            if let host = url.host {
                switch host {
                case "firstTutorial":
                    needFirstTutorial = true
                case "safariSettings":
                    openSafariTutorialView = true
                case "home":
                    selection = nil
                default:
                    selection = NavigationItem(rawValue: host)
                }
            }
        }
    }
}
