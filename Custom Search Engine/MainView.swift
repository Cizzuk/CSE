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
    @State private var needTutorial = true
    
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
                } footer: {
                    Text("TopUrl-Desc")
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
                } footer: {
                    Text("SuffixUrl-Desc")
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
                    .onChange(of: searchengine) { entered in
                        userDefaults!.set(entered, forKey: "searchengine")
                    }
                } header: {
                    Text("SafariSetting")
                } footer: {
                    VStack (alignment : .leading) {
                        #if iOS
                        Text("DefaultSE-Desc-iOS")
                        Spacer()
                        Text("SafariSetting-Desc-iOS")
                        #elseif macOS
                        Text("DefaultSE-Desc-macOS")
                        Spacer()
                        Text("SafariSetting-Desc-macOS")
                        #elseif visionOS
                        Text("DefaultSE-Desc-visionOS")
                        Spacer()
                        Text("SafariSetting-Desc-visionOS")
                        #endif
                    }
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
        .sheet(isPresented: $needTutorial, content: { TutorialView() })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
