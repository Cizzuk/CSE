//
//  MainView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/03/13.
//

import SwiftUI
#if iOS
import WidgetKit
#endif

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
    @AppStorage("usePrivateCSE", store: userDefaults) private var usePrivateCSE: Bool = false
    @State private var usePrivateCSEToggle: Bool = false
    @AppStorage("useQuickCSE", store: userDefaults) private var useQuickCSE: Bool = false
    @State private var useQuickCSEToggle: Bool = false
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
        NavigationStack {
            List {
                // Normal CSE Settings
                Section {
                    // Default CSE
                    NavigationLink(destination: EditSEView(cseType: .defaultCSE)) {
                        Text("Default Search Engine")
                    }
                    
                    // Private CSE
                    Toggle(isOn: $usePrivateCSE.animation()) {
                        Text("Use different search engine in Private Browse")
                    }
                    .onChange(of: usePrivateCSE) { _ in
                        withAnimation {
                            usePrivateCSEToggle = usePrivateCSE
                        }
                    }
                    if usePrivateCSEToggle {
                        NavigationLink(destination: EditSEView(cseType: .privateCSE)) {
                            Text("Private Search Engine")
                        }
                    }
                }
                
                // Quick SE Settings
                Section {
                    Toggle(isOn: $useQuickCSE.animation()) {
                        Text("Quick Search")
                    }
                    .onChange(of: useQuickCSE) { _ in
                        withAnimation {
                            useQuickCSEToggle = useQuickCSE
                        }
                        #if iOS
                        if #available(iOS 18.0, *) {
                            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.QuickSearch")
                        }
                        #endif
                    }
                    if useQuickCSEToggle {
                        NavigationLink(destination: QuickSEListView()) {
                            Text("Quick Search Engines")
                        }
                    }
                } footer: {
                    Text("Enter the keyword at the top to switch search engines.")
                }
                
                
                // Emojipedia Search Setting
                Section {
                    Toggle(isOn: $useEmojiSearch) {
                        Text("Emoji Search")
                    }
                    #if iOS
                    .onChange(of: useEmojiSearch) { _ in
                        if #available(iOS 18.0, *) {
                            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.EmojiSearch")
                        }
                    }
                    #endif
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
                    NavigationLink(destination: LicenseView()) {
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
            .task {
                // Initialize
                usePrivateCSEToggle = usePrivateCSE
                useQuickCSEToggle = useQuickCSE
            }
        }
        .navigationViewStyle(.stack)
        // Tutorial sheets
        .sheet(isPresented : $needFirstTutorial, content: {
            FullTutorialView(isOpenSheet: $needFirstTutorial)
        })
        .sheet(isPresented: $needSafariTutorial, content: {
            SafariTutorialView(isOpenSheet: $needSafariTutorial)
        })
        .sheet(isPresented: $openSafariTutorialView, content: {
            SafariTutorialView(isOpenSheet: $openSafariTutorialView)
        })
    }
}
