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
        .foregroundColor(.white)
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor)
        .cornerRadius(12)
}

struct FullTutorialView: View {
    @Binding var isOpenSheet: Bool
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Welcome to CSE")
                
                VStack(spacing: 16) {
                    Text("Before you can start using CSE, you need to do some setup.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                NavigationLink {
                    SafariTutorialView(isOpenSheet: $isOpenSheet)
                } label: {
                    NextButton(text: "Next")
                }
                .padding(.horizontal, 24)
                Button(action: {
                    dismiss()
                }) {
                    Text("Skip")
                }
                .padding(.bottom, 24)
            }
        }
        .interactiveDismissDisabled()
    }
}

struct SafariTutorialView: View {
    @Binding var isOpenSheet: Bool
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? ""
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Safari Settings")
                
                VStack(spacing: 16) {
                    Text("Please make sure that the following items are the same as your Safari settings")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                    
                List {
                    Section {
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
                    } footer: {
                        VStack (alignment : .leading) {
                            #if macOS
                            Text("Open Safari, go to Safari → Settings... and select 'Search' tab to find these settings.")
                            #else
                            Text("You can find these settings in Settings → Apps → Safari.")
                            #endif
                            Spacer()
                            Text("If you set another search engine in private browsing, you can set another custom search engine in a private window.")
                        }
                    }
                }
                
                
                NavigationLink {
                    SafariTutorialSecondView(isOpenSheet: self.$isOpenSheet)
                } label: {
                    NextButton(text: "Next")
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SafariTutorialSecondView: View {
    @Binding var isOpenSheet: Bool
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @AppStorage("searchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var searchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "google"
    @AppStorage("alsousepriv", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var alsousepriv: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "alsousepriv")
    @AppStorage("privsearchengine", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var privsearchengine: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "privsearchengine") ?? ""
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Safari Settings")
                
                VStack(spacing: 16) {
                    Text("Please allow CSE at the following webpage")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                    
                List {
                    Section {} footer: {
                        #if macOS
                        Text("Open Safari, go to Safari → Settings..., select 'Extensions' tab and enable CSE. Then 'Allow' the following webpage from 'Edit Websites...' button")
                        #else
                        Text("Go to Settings → Apps → Safari → Extensions → Customize Search Engine and allow extension. Then 'Allow' the following webpage")
                        #endif
                    }
                    Section {
                        let currentRegion = Locale.current.regionCode
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
                        if searchengine == "bing" || (!alsousepriv && privsearchengine == "bing") {
                            Text("bing.com")
                        }
                        if searchengine == "duckduckgo" || (!alsousepriv && privsearchengine == "duckduckgo") {
                            Text("duckduckgo.com")
                        }
                        if searchengine == "ecosia" || (!alsousepriv && privsearchengine == "ecosia") {
                            Text("ecosia.org")
                        }
                        if searchengine == "baidu" || (!alsousepriv && privsearchengine == "baidu") {
                            Text("baidu.com")
                        }
                        if searchengine == "sogou" || (!alsousepriv && privsearchengine == "sogou") {
                            Text("sogou.com")
                        }
                        if searchengine == "360search" || (!alsousepriv && privsearchengine == "360search") {
                            Text("so.com")
                        }
                        if searchengine == "yandex" || (!alsousepriv && privsearchengine == "yandex") {
                            Text("yandex.ru")
                        }
                    }
                }
                
                
                Button(action: {
                    isOpenSheet = false
                }) {
                    NextButton(text: "Done")
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CreateCSETutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Create your CSE")
                
                VStack(spacing: 16) {
                    Text("")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    NextButton(text: "Next")
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
