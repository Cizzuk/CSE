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
    @State private var openTutorial = false
    @State private var requestTutorial: [String] = ["setupsafari", "createcse"]
    
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
                    Text("TopUrl")
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
                    Text("SuffixUrl")
                }
                
                // Default SE Section
                Section {
                    Picker("DefaultSE", selection: $searchengine) {
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
                        Text("AlsoUseInPrivate")
                    })
                    .onChange(of: alsousepriv) { newValue in
                        userDefaults!.set(newValue, forKey: "alsousepriv")
                    }
                    
                    if !alsousepriv {
                        Picker("PrivDefaultSE", selection: $privsearchengine) {
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
                    Text("SafariSetting")
                }
                
                #if iOS
                Section {
                    NavigationLink(destination: linkDestination, isActive: $isIconSettingView) {
                        Image((alternateIconName ?? "appicon") + "-pre")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .id(isIconSettingView)
                            .accessibilityIgnoresInvertColors(true)
                        Text("ChangeAppIcon")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                } header: {
                    Text("AppIcon")
                }
                #endif
                
                // Tutorial Section
                Section {
                    Button(action: {
                        requestTutorial = ["setupsafari", "createcse"]
                        openTutorial = true
                    }) {
                        Text("Tutorial-full")
                    }
                    Button(action: {
                        requestTutorial = ["setupsafari"]
                        openTutorial = true
                    }) {
                        Text("Tutorial-Full-setupsafari")
                    }
                    Button(action: {
                        requestTutorial = ["createcse"]
                        openTutorial = true
                    }) {
                        Text("Tutorial-createcse")
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
                            Text("ContactLink")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // Privacy Policy
                    Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .frame(width: 20.0)
                            Text("PrivacyPolicyLink")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // License Link
                    Link(destination:URL(string: "https://www.mozilla.org/en-US/MPL/2.0/")!, label: {
                        HStack {
                            Image(systemName: "book.closed")
                                .frame(width: 20.0)
                            Text("LicenseLink")
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
                            Text("SourceLink")
                            Spacer()
                            Text("GitHub")
                            Image(systemName: "chevron.right")
                        }
                    })
                } header: {
                    Text("SupportLink")
                } footer: {
                    HStack {
                        Text("© Cizzuk")
                        Spacer()
                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                    }
                }
                
                Section {
                    NavigationLink(destination: AdvSettingView().navigationTitle("AdvSettings")) {
                        Text("AdvSettings")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("CSESetting")
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $openTutorial, content: {
            TutorialView(requestTutorial: $requestTutorial)
        })
        .sheet(isPresented: $needFirstTutorial, content: {
            TutorialView(requestTutorial: $requestTutorial)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
