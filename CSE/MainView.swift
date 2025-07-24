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
    
    #if iOS
    // Get current icon
    private var alternateIconName: String? {
        UIApplication.shared.alternateIconName
    }
    // Purchased ChangeIcon?
    @ObservedObject var storeManager = StoreManager()
    private var linkDestination: some View {
        if UserDefaults().bool(forKey: "haveIconChange") {
            return AnyView(IconSettingView())
        } else {
            return AnyView(PurchaseView())
        }
    }
    #endif
    
    var body: some View {
        #if IOS
        @ObservedObject var storeManager = StoreManager()
        #endif
        NavigationSplitView {
            List {
                // Default SE Settings
                Section {
                    NavigationLink(destination: EditSE.EditDefaultCSEView()) {
                        HStack {
                            Text("Default Search Engine")
                            Spacer()
                            Text(useDefaultCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Private SE Settings
                    NavigationLink(destination: EditSE.EditPrivateCSEView()) {
                        HStack {
                            Text("Private Search Engine")
                            Spacer()
                            Text(usePrivateCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Quick SE Settings
                    NavigationLink(destination: QuickSEListView()) {
                        HStack {
                            Text("Quick Search")
                            Spacer()
                            Text(useQuickCSE ? "On" : "Off")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    
                    // Emoji Search Setting
                    NavigationLink(destination: EmojiSearchView()) {
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
                                #if !visionOS
                                .foregroundColor(.accentColor)
                                #endif
                            Text("If you change your Safari settings or CSE does not work properly, you may need to redo this tutorial.")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
//                IMPORTANT: This code is not currently used, but it is kept here for future reference.
//                #if iOS
//                // Go IconChange View for iOS/iPadOS
//                Section {
//                    NavigationLink(destination: linkDestination) {
//                        Image((alternateIconName ?? "appicon") + "-pre")
//                            .resizable()
//                            .frame(width: 64, height: 64)
//                            .accessibilityHidden(true)
//                            .cornerRadius(14)
//                            .padding(4)
//                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                        Text("Change App Icon")
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                }
//                #endif
                
                // Support Section
                Section {
                    Group {
                        // Contact Link
                        Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                            HStack {
                                Image(systemName: "message")
                                    .frame(width: 20.0)
                                Text("Contact")
                            }
                        })
                        // GitHub Source Link
                        Link(destination:URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                            HStack {
                                Image(systemName: "ladybug")
                                    .frame(width: 20.0)
                                Text("Source")
                                Spacer()
                            }
                        })
                        // Privacy Policy Link
                        Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .frame(width: 20.0)
                                Text("Privacy Policy")
                            }
                        })
                        // About View
                        NavigationLink(destination: AboutView()) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .frame(width: 20.0)
                                Text("About")
                            }
                        }
                    }
                    #if !visionOS
                    .foregroundColor(.accentColor)
                    #endif
                } header: {
                    Text("Support")
                }
                
                // Advanced Settings
                Section {
                    // TODO: Remove this button if CTF issues are resolved. (issue#24)
                    #if iOS
                    // Go IconChange View for iOS/iPadOS
                    NavigationLink(destination: linkDestination) {
                        Text("Change App Icon")
                    }
                    #endif
                    
                    NavigationLink(destination: AdvSettingView()) {
                        Text("Advanced Settings")
                    }
                }
                
            }
            .navigationTitle("CSE Settings")
        } detail: {
            NavigationStack {
                Spacer()
            }
        }
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
