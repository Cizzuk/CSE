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
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    var body: some View {
        NavigationView {
            List {
                // Top Section
                Section {
                    TextField("", text: .constant(userDefaults!.string(forKey: "urltop") ?? "https://archive.org/search?query="))
                        .disableAutocorrection(true)
                    
                } header: {
                    Text("Top of URL")
                }
                
                // Suffix Section
                Section {
                    TextField("", text: .constant(userDefaults!.string(forKey: "urlsuffix") ?? ""))
                        .disableAutocorrection(true)
                } header: {
                    Text("Suffix of URL")
                }
                
                // Default SE Section
                Section {
                    Picker("Default Search Engine", selection: .constant(userDefaults!.string(forKey: "searchengine") ?? "duckduckgo")) {
                        Text("DuckDuckGo").tag("duckduckgo")
                        Text("Sogou").tag("sogou")
                        Text("Yandex").tag("yandex")
                    }
                } header: {
                    Text("Safari Settings")
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
                            Text("Mozilla Public License 2.0")
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
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("CSE Settings")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
