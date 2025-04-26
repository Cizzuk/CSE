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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // Load app settings
    @AppStorage("usePrivateCSE", store: userDefaults)
      private var usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
    @AppStorage("useQuickCSE", store: userDefaults)
      private var useQuickCSE: Bool = userDefaults.bool(forKey: "useQuickCSE")
    @AppStorage("useEmojiSearch", store: userDefaults)
      private var useEmojiSearch: Bool = userDefaults.bool(forKey: "useEmojiSearch")
    
    // Sheets
    @AppStorage("needFirstTutorial", store: userDefaults)
      private var needFirstTutorial: Bool = userDefaults.bool(forKey: "needFirstTutorial")
    @AppStorage("needSafariTutorial", store: userDefaults)
      private var needSafariTutorial: Bool = userDefaults.bool(forKey: "needSafariTutorial")
    @State private var openSafariTutorialView: Bool = false
    
    @State private var defaultCSE: [String: Any] = [:]
    @State private var privateCSE: [String: Any] = [:]
    
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
        NavigationView {
            List {
                // Normal CSE Settings
                Section {
                    // Default CSE
                    NavigationLink {
                        EditSEView(cseType: .constant("default"), cseID: .constant(""), exCSEData: .constant(defaultCSE))
                    } label: {
                        Text("Default Search Engine")
                    }
                    
                    // Private CSE
                    Toggle(isOn: $usePrivateCSE, label: {
                        Text("Use different search engine in Private Browse")
                    })
                    if usePrivateCSE {
                        NavigationLink {
                            EditSEView(cseType: .constant("private"), cseID: .constant(""), exCSEData: .constant(privateCSE))
                        } label: {
                            Text("Private Search Engine")
                        }
                    }
                }
                
                // Quick SE Settings
                Section {
                    Toggle(isOn: $useQuickCSE, label: {
                        Text("Quick Search")
                    })
                    if useQuickCSE {
                        NavigationLink {
                            QuickSEListView()
                        } label: {
                            Text("Quick Search Engines")
                        }
                    }
                } footer: {
                    Text("Enter the keyword at the top to switch search engines.")
                }
                
                
                // Emojipedia Search Setting
                Section {
                    Toggle(isOn: $useEmojiSearch, label: {
                        Text("Emoji Search")
                    })
                } footer: {
                    Text("If you enter only one emoji, you can search on Emojipedia.org.")
                }
                
                // Show Safari Settings Tutorial Button
                Section {
                    Button(action: {
                        openSafariTutorialView = true
                    }) {
                        HStack {
                            Image(systemName: "safari")
                                .frame(width: 20.0)
                                .accessibilityHidden(true)
                            Text("Safari Settings")
                        }
                    }
                } footer: {
                    Text("If you change your Safari settings or CSE does not work properly, you may need to redo this tutorial.")
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
                    // Contact Link
                    Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                        HStack {
                            Image(systemName: "message")
                                .frame(width: 20.0)
                            Text("Contact")
                        }
                    })
                    // Privacy Policy
                    Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .frame(width: 20.0)
                            Text("Privacy Policy")
                        }
                    })
                    // License Link
                    NavigationLink {
                        LicenseView()
                    } label: {
                        HStack {
                            Image(systemName: "book.closed")
                                .frame(width: 20.0)
                            Text("License")
                        }
                        #if !visionOS
                        .foregroundColor(.accentColor)
                        #endif
                    }
                    // GitHub Source Link
                    Link(destination:URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                        HStack {
                            Image(systemName: "ladybug")
                                .frame(width: 20.0)
                            Text("Source")
                            Spacer()
                        }
                    })
                } header: {
                    Text("Support")
                } footer: {
                    HStack {
                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                        Spacer()
                        Text("© Cizzuk")
                    }
                }
                
                // Advanced Settings
                Section {
                    // TODO: Remove this button if CTF issues are resolved. (issue#24)
                    #if iOS
                    // Go IconChange View for iOS/iPadOS
                    NavigationLink(destination: linkDestination) {
                        Text("Change App Icon")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    #endif
                    
                    NavigationLink(destination: AdvSettingView().navigationTitle("Advanced Settings")) {
                        Text("Advanced Settings")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                
            }
            .navigationTitle("CSE Settings")
            .listStyle(.insetGrouped)
            .animation(.easeOut(duration: 0.2), value: usePrivateCSE)
            .animation(.easeOut(duration: 0.2), value: useQuickCSE)
            .task {
                // Initialize
                defaultCSE = userDefaults.dictionary(forKey: "defaultCSE") ?? [:]
                privateCSE = userDefaults.dictionary(forKey: "privateCSE") ?? [:]
            }
        }
        .navigationViewStyle(.stack)
        // Tutorial sheets
        .sheet(isPresented: $needFirstTutorial, content: {
            FullTutorialView(isOpenSheet: $needFirstTutorial, isFirstTutorial: .constant(true))
        })
        .sheet(isPresented: $needSafariTutorial, content: {
            SafariTutorialView(isOpenSheet: $needSafariTutorial, isFirstTutorial: .constant(false))
        })
        .sheet(isPresented: $openSafariTutorialView, content: {
            SafariTutorialView(isOpenSheet: $openSafariTutorialView, isFirstTutorial: .constant(false))
        })
    }
}
