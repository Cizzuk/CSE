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
    let currentRegion = Locale.current.regionCode
    
    //Load app settings
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? "duckduckgo"
    
    @AppStorage("usePrivateCSE", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var usePrivateCSE: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "usePrivateCSE")
    @AppStorage("useQuickCSE", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var useQuickCSE: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "useQuickCSE")
    @AppStorage("useEmojiSearch", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var useEmojiSearch: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "useEmojiSearch")
    
    @AppStorage("needFirstTutorial", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var needFirstTutorial: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "needFirstTutorial")
    @State private var openSafariTutorialView: Bool = false
    
    #if iOS
    // Icon change for iOS/iPadOS
    @State private var isIconSettingView: Bool = false
    // Get current icon
    var alternateIconName: String? {
        UIApplication.shared.alternateIconName
    }
    // Purchased ChangeIcon?
    @ObservedObject var storeManager = StoreManager()
    var linkDestination: some View {
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
                        EditSEView(cseType: .constant("default"), cseID: .constant(""))
                    } label: {
                        Text("Default Search Engine")
                    }
                    
                    // Private CSE
                    if #available(iOS 17.0, macOS 14.0, *) {
                        // If private CSE is not available due to Safari settings
                        if alsousepriv || searchengine == privsearchengine {
                            Toggle(isOn: .constant(false), label: {
                                Text("Use different search engine in Private Browse")
                            })
                            .disabled(true)
                        } else { // is available
                            Toggle(isOn: $usePrivateCSE, label: {
                                Text("Use different search engine in Private Browse")
                            })
                            if usePrivateCSE {
                                NavigationLink {
                                    EditSEView(cseType: .constant("private"), cseID: .constant(""))
                                } label: {
                                    Text("Private Search Engine")
                                }
                            }
                        }
                    }
                } footer: {
                    if #available(iOS 17.0, macOS 14.0, *),
                    (alsousepriv || searchengine == privsearchengine) { // is not available
                        Text("If you set another search engine in private browsing in Safari settings, you can use another custom search engine in private browse.")
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
                        Text("Safari Settings")
                    }
                } footer: {
                    Text("If you change your Safari settings or CSE does not work properly, you may need to redo this tutorial.")
                }
                
//                TODO: Remove comments if CTF issues are resolved. (issue#24)
//                #if iOS
//                // Go IconChange View for iOS/iPadOS
//                Section {
//                    NavigationLink(destination: linkDestination, isActive: $isIconSettingView) {
//                        Image((alternateIconName ?? "appicon") + "-pre")
//                            .resizable()
//                            .frame(width: 64, height: 64)
//                            .accessibilityHidden(true)
//                            .cornerRadius(14)
//                            .padding(4)
//                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                            .id(isIconSettingView)
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
                        .foregroundColor(.accentColor)
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
                    NavigationLink(destination: linkDestination, isActive: $isIconSettingView) {
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
            .listStyle(.insetGrouped)
            .navigationTitle("CSE Settings")
        }
        .navigationViewStyle(.stack)
        // Tutorial sheets
        .sheet(isPresented: $needFirstTutorial, content: {
            FullTutorialView(isOpenSheet: $needFirstTutorial)
        })
        .sheet(isPresented: $openSafariTutorialView, content: {
            SafariTutorialView(isOpenSheet: $openSafariTutorialView)
        })
    }
}
