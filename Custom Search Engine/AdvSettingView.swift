//
//  AdvSettingView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

import SwiftUI

struct AdvSettingView: View {
    //Load advanced settings
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
    @AppStorage("adv_disablechecker", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var disablechecker: Bool = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.bool(forKey: "adv_disablechecker")
    @AppStorage("adv_resetCSEs", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var resetCSEs: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "adv_resetCSEs") ?? ""
    @State private var allowReset: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Reset All Advanced Settings") {
                        userDefaults!.set(false, forKey: "adv_disablechecker")
                        userDefaults!.set("", forKey: "adv_resetCSEs")
                        allowReset = false
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
                    Toggle(isOn: $allowReset, label: {
                        Text("Enable Reset Buttons")
                    })
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
                    Text("Existing data will be deleted at next startup: " + resetCSEs)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
