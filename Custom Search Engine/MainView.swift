//
//  MainView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/03/13.
//

import SwiftUI

@main
struct MainView: App {
#if iOS
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    //Load app settings
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @AppStorage("urltop", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var urltop: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urltop") ?? "https://archive.org/search?query="
    @AppStorage("urlsuffix", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var urlsuffix: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urlsuffix") ?? ""
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? ""
    
    @AppStorage("needFirstTutorial", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var needFirstTutorial: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "needFirstTutorial")
    @State private var openSafariTutorialView = false
    @State private var openCreateCSETutorialView = false
    
#if iOS
    @State private var isIconSettingView: Bool = false
    var alternateIconName: String? {
        UIApplication.shared.alternateIconName
    }
    
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
                // Top Section
                Section {
                    TextField("", text: $urltop)
                        .disableAutocorrection(true)
#if iOS
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
#endif
                        .onChange(of: urltop) { entered in
                            userDefaults!.set(entered, forKey: "urltop")
                        }
                    
                } header: {
                    Text("Top of URL")
                }
                
                // Suffix Section
                Section {
                    TextField("", text: $urlsuffix)
                        .disableAutocorrection(true)
#if iOS
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
#endif
                        .onChange(of: urlsuffix) { entered in
                            userDefaults!.set(entered, forKey: "urlsuffix")
                        }
                } header: {
                    Text("Suffix of URL")
                }
                
                // Default SE Section
                Section {
                    Picker("Default Search Engine", selection: $searchengine) {
                        let currentRegion = Locale.current.regionCode
                        if currentRegion == "CN" {
                            Text("Baidu").tag("baidu")
                            Text("Sogou").tag("sogou")
                            Text("360 Search").tag("360search")
                        }
                        Text("Google").tag("google")
                        Text("Yahoo").tag("yahoo")
                        Text("Bing").tag("bing")
                        if currentRegion == "RU" {
                            Text("Yandex").tag("yandex")
                        }
                        Text("DuckDuckGo").tag("duckduckgo")
                        Text("Ecosia").tag("ecosia")
                    }
                    .onChange(of: searchengine) { newValue in
                        userDefaults!.set(newValue, forKey: "searchengine")
                        if alsousepriv == true {
                            let currentRegion = Locale.current.regionCode
                            if currentRegion == "CN" {
                                if searchengine == "duckduckgo" {
                                    userDefaults!.set("baidu", forKey: "privsearchengine")
                                } else {
                                    userDefaults!.set("duckduckgo", forKey: "privsearchengine")
                                }
                            } else {
                                if searchengine == "duckduckgo" {
                                    userDefaults!.set("google", forKey: "privsearchengine")
                                } else {
                                    userDefaults!.set("duckduckgo", forKey: "privsearchengine")
                                }
                            }
                        }
                    }
                    
                    Toggle(isOn: $alsousepriv, label: {
                        Text("Also Use in Private Browsing")
                    })
                    .onChange(of: alsousepriv) { newValue in
                        userDefaults!.set(newValue, forKey: "alsousepriv")
                    }
                    
                    if !alsousepriv {
                        Picker("Private Search Engine", selection: $privsearchengine) {
                            let currentRegion = Locale.current.regionCode
                            if currentRegion == "CN" {
                                Text("Baidu").tag("baidu")
                                Text("Sogou").tag("sogou")
                                Text("360 Search").tag("360search")
                            }
                            Text("Google").tag("google")
                            Text("Yahoo").tag("yahoo")
                            Text("Bing").tag("bing")
                            if currentRegion == "RU" {
                                Text("Yandex").tag("yandex")
                            }
                            Text("DuckDuckGo").tag("duckduckgo")
                            Text("Ecosia").tag("ecosia")
                        }
                        .onChange(of: privsearchengine) { newValue in
                            userDefaults!.set(newValue, forKey: "privsearchengine")
                        }
                    }
                } header: {
                    Text("Safari Settings")
                } footer: {
                    Text("If you have changed your Safari settings, you may need to redo the tutorial.")
                }
                
                #if iOS
                Section {
                    NavigationLink(destination: linkDestination, isActive: $isIconSettingView) {
                        Image((alternateIconName ?? "appicon") + "-pre")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .accessibilityHidden(true)
                            .cornerRadius(14)
                            .padding(4)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .id(isIconSettingView)
                        Text("Change App Icon")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                } header: {
                    Text("App Icon")
                }
                #endif
                
                // Tutorial Section
                Section {
                    Button(action: {
                        openSafariTutorialView = true
                    }) {
                        Text("Safari Settings")
                    }
                    Button(action: {
                        openCreateCSETutorialView = true
                    }) {
                        Text("Create your CSE")
                    }
                } header: {
                    Text("Tutorials")
                }
                
                // Support Section
                Section {
                    // Contact Link
                    Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                        HStack {
                            Image(systemName: "message")
                                .frame(width: 20.0)
                            Text("Contact")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // Privacy Policy
                    Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .frame(width: 20.0)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // License Link
                    Link(destination:URL(string: "https://www.mozilla.org/en-US/MPL/2.0/")!, label: {
                        HStack {
                            Image(systemName: "book.closed")
                                .frame(width: 20.0)
                            Text("License")
                            Spacer()
                            Text("MPL 2.0")
                            Image(systemName: "chevron.right")
                        }
                    })
                    // GitHub Source Link
                    Link(destination:URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                        HStack {
                            Image(systemName: "ladybug")
                                .frame(width: 20.0)
                            Text("Source")
                            Spacer()
                            Text("GitHub")
                            Image(systemName: "chevron.right")
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
                
                Section {
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
        .sheet(isPresented: $needFirstTutorial, content: {
            FullTutorialView()
        })
        .sheet(isPresented: $openSafariTutorialView, content: {
            SafariTutorialView()
        })
        .sheet(isPresented: $openCreateCSETutorialView, content: {
            CreateCSETutorialView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
