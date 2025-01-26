//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

private func HeaderText(text: String) -> some View {
    Text(text)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 40)
}

private func NextButton(text: String) -> some View {
    Text(text)
        .font(.headline)
        .padding()
        #if !visionOS
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(12)
        #endif
}

// First Tutorial
struct FullTutorialView: View {
    @Binding var isOpenSheet: Bool
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Welcome to CSE", comment: ""))
                VStack() {
                    Text("Before you can start using CSE, you need to do some setup.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                NavigationLink {
                    SafariTutorialView(isOpenSheet: $isOpenSheet)
                } label: {
                    NextButton(text: NSLocalizedString("Next", comment: ""))
                }
                .padding(.horizontal, 24)
                Button(action: {
                    isOpenSheet = false
                }) {
                    Text("Skip")
                }
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 24, trailing: 0))
            }
        }
        .interactiveDismissDisabled()
    }
}

// Set Safari settings
struct SafariTutorialView: View {
    let currentRegion = Locale.current.regionCode
    @Binding var isOpenSheet: Bool
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? "duckduckgo"
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Safari Settings", comment: ""))
                VStack() {
                    Text("Please make sure that the following items are the same as your Safari settings")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                    
                List {
                    Section {
                        // Default SE
                        Picker("Search Engine", selection: $searchengine) {
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
                        
                        Toggle(isOn: $alsousepriv, label: {
                            Text("Also Use in Private Browsing")
                        })
                        
                        // Private SE
                        if !alsousepriv {
                            Picker("Private Search Engine", selection: $privsearchengine) {
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
                        }
                    } footer: {
                        VStack (alignment : .leading) {
                            #if macOS
                            Text("Open Safari, go to Safari → Settings... and select 'Search' tab to find these settings.")
                            #else
                            Text("You can find these settings in Settings → Apps → Safari.")
                            #endif
                            Spacer()
                            Text("If you set another search engine in private browsing in Safari settings, you can use another custom search engine in private browse.")
                        }
                    }
                }
                
                NavigationLink {
                    SafariTutorialSecondView(isOpenSheet: self.$isOpenSheet)
                } label: {
                    NextButton(text: NSLocalizedString("Next", comment: ""))
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

struct SafariTutorialSecondView: View {
    let currentRegion = Locale.current.regionCode
    @Binding var isOpenSheet: Bool
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? "duckduckgo"
    var body: some View {
        NavigationView {
            VStack() {
                HeaderText(text: NSLocalizedString("Safari Settings", comment: ""))
                VStack() {
                    Text("Please allow CSE at the following webpage")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                List {
                    Section {} footer: {
                        #if macOS
                        Text("Open Safari, go to Safari → Settings..., select 'Extensions' tab and enable CSE. Then 'Allow' the following webpage from 'Edit Websites...' button.")
                        #else
                        Text("Go to Settings → Apps → Safari → Extensions → Customize Search Engine and allow extension. Then 'Allow' the following webpage.")
                        #endif
                    }
                    
                    // Show domains that need to allow
                    Section {
                        if searchengine == "baidu" || (!alsousepriv && privsearchengine == "baidu") {
                            Text("baidu.com")
                        }
                        if searchengine == "bing" || (!alsousepriv && privsearchengine == "bing") {
                            Text("bing.com")
                        }
                        if searchengine == "duckduckgo" || (!alsousepriv && privsearchengine == "duckduckgo") {
                            Text("duckduckgo.com")
                        }
                        if searchengine == "ecosia" || (!alsousepriv && privsearchengine == "ecosia") {
                            Text("ecosia.org")
                        }
                        if searchengine == "google" || (!alsousepriv && privsearchengine == "google") {
                            if currentRegion == "CN" {
                                Text("google.cn")
                            } else {
                                Text("google.com")
                            }
                        }
                        if searchengine == "yahoo" || (!alsousepriv && privsearchengine == "yahoo") {
                            if currentRegion == "JP" {
                                Text("search.yahoo.co.jp")
                            } else {
                                Text("search.yahoo.com")
                            }
                        }
                        if searchengine == "360search" || (!alsousepriv && privsearchengine == "360search") {
                            Text("so.com")
                        }
                        if searchengine == "sogou" || (!alsousepriv && privsearchengine == "sogou") {
                            Text("sogou.com")
                        }
                        if searchengine == "yandex" || (!alsousepriv && privsearchengine == "yandex") {
                            Text("yandex.ru")
                        }
                    }
                }
                
                Button(action: {
                    isOpenSheet = false
                }) {
                    NextButton(text: NSLocalizedString("Done", comment: ""))
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}
