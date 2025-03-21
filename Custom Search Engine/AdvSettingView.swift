//
//  AdvSettingView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

import SwiftUI

struct AdvSettingView: View {
    //Load advanced settings
    @AppStorage("needFirstTutorial", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var needFirstTutorial: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "needFirstTutorial")
    @AppStorage("adv_disablechecker", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var disablechecker: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "adv_disablechecker")
    @AppStorage("adv_ignoreFocusFilter", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var ignoreFocusFilter: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "adv_ignoreFocusFilter")
    @AppStorage("adv_ignorePOSTFallback", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var ignorePOSTFallback: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "adv_ignorePOSTFallback")
    @AppStorage("adv_resetCSEs", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var resetCSEs: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "adv_resetCSEs") ?? ""
    @State private var allowReset: Bool = false
    
    var body: some View {
        List {
            Section {
                Button("Reset All Advanced Settings") {
                    disablechecker = false
                    ignoreFocusFilter = false
                    #if macOS
                    ignorePOSTFallback = true
                    #else
                    ignorePOSTFallback = false
                    #endif
                    resetCSEs = ""
                    allowReset = false
                }
            }
            
            Section {
                Button("Redo First Tutorial") {
                    needFirstTutorial = true
                }
            }
            
            Section {
                Toggle(isOn: $disablechecker, label: {
                    Text("Disable Checker")
                })
            } footer: {
                Text("CSE will not check that you have searched from the search bar.")
            }
            
            Section {
                Toggle(isOn: $ignoreFocusFilter, label: {
                    Text("Ignore Focus Filter")
                })
            } footer: {
                Text("CSE will ignore all Focus Filters.")
            }
            
            Section {
                Toggle(isOn: $ignorePOSTFallback, label: {
                    Text("Ignore POST Fallback")
                })
            } footer: {
                Text("When using custom search engines with POST, to bypass CSP restrictions, the process redirects to a page created by CSE and then redirects again to your custom search engine. However, this mechanism does not work correctly in some environments (as far as I have researched, macOS). Enabling this setting will redirect directly to your custom search engine without bypassing CSP restrictions. However, for some Safari search engines with strict CSP settings (as far as I have researched, DuckDuckGo), it will not be possible to use a search engine with POST.")
            }
            
            Section {
                Toggle(isOn: $allowReset, label: {
                    Text("Enable Reset Buttons")
                })
                .onChange(of: allowReset) { _ in
                    if !allowReset {
                        resetCSEs = ""
                    }
                }
                Button(action: {
                    resetCSEs = "default"
                }) {
                    Text("Reset Default Search Engine")
                }
                .disabled(!allowReset)
                Button(action: {
                    resetCSEs = "private"
                }) {
                    Text("Reset Private Search Engine")
                }
                .disabled(!allowReset)
                Button(action: {
                    resetCSEs = "quick"
                }) {
                    Text("Reset Quick Search Engines")
                }
                .disabled(!allowReset)
                Button(action: {
                    resetCSEs = "all"
                }) {
                    Text("Reset All Custom Search Engines")
                }
                .disabled(!allowReset)
            } footer: {
                Text("Existing data will be deleted at next startup: \(resetCSEs)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
    }
}
