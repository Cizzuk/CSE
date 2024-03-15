//
//  SettingView.swift
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
    
    //Load app settings
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @State private var urltop = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urltop") ?? "https://archive.org/search?query="
    @State private var urlsuffix = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "urlsuffix") ?? ""
    @State private var searchengine = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "searchengine") ?? "duckduckgo"
    
    var body: some View {
        NavigationView {
            List {
                // Top Section
                Section {
                    TextField("", text: $urltop)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onChange(of: urltop) { entered in
                            userDefaults!.set(entered, forKey: "urltop")
                        }
                    
                } header: {
                    Text("Top of URL")
                } footer: {
                    Text(verbatim: "For example, if you search for \"TYPEDTEXT\" and \"https://example.com/?q=TYPEDTEXT&kp=-2\" is your URL, enter \"https://example.com/?q=\".")
                }
                
                // Suffix Section
                Section {
                    TextField("", text: $urlsuffix)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onChange(of: urlsuffix) { entered in
                            userDefaults!.set(entered, forKey: "urlsuffix")
                        }
                } header: {
                    Text("Suffix of URL")
                } footer: {
                    Text(verbatim: "And here, enter \"&kp=-2\" after \"TYPEDTEXT\".")
                }
                
                // Default SE Section
                Section {
                    Picker("Default Search Engine", selection: $searchengine) {
                        Text("DuckDuckGo").tag("duckduckgo")
                        Text("Sogou").tag("sogou")
                        Text("Yandex").tag("yandex")
                    }
                    .onChange(of: searchengine) { entered in
                        userDefaults!.set(entered, forKey: "searchengine")
                    }
                } header: {
                    Text("Safari Setting")
                } footer: {
                    VStack (alignment : .leading) {
                        Text(verbatim: "You will need to change the setting in Settings > Safari > Search Engine.")
                        Spacer()
                        Text(verbatim: "And please allow CSE in Settings > Safari > Extentions.")
                    }
                }
            
                
                Section {
                    HStack {
                        
                    }
                } header: {
                    Text("App Icon")
                }
                
                // Support Section
                Section {
                    // Contact Link
                    Link(destination:URL(string: "https://cizzuk.net/contact/")!, label: {
                        HStack{
                            Text("Contact")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // Privacy Policy
                    Link(destination:URL(string: "https://tsg0o0.com/privacy/")!, label: {
                        HStack{
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    })
                    // License Link
                    Link(destination:URL(string: "https://www.mozilla.org/en-US/MPL/2.0/")!, label: {
                        HStack{
                            Text("License")
                            Spacer()
                            Text("MPL 2.0")
                            Image(systemName: "chevron.right")
                        }
                    })
                    // GitHub Source Link
                    Link(destination:URL(string: "https://github.com/tsg0o0/CSE-iOS")!, label: {
                        HStack{
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
                        Text("© Cizzuk")
                        Spacer()
                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("CSE Settings")
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
