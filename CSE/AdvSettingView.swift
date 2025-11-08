//
//  AdvSettingView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

import SwiftUI

struct AdvSettingView: View {
    //Load advanced settings
    @AppStorage("needFirstTutorial", store: userDefaults) private var needFirstTutorial: Bool = true
    @AppStorage("adv_disablechecker", store: userDefaults) private var disablechecker: Bool = false
    @AppStorage("adv_ignoreSafariSettings", store: userDefaults) private var ignoreSafariSettings: Bool = false
    @AppStorage("adv_ignoreFocusFilter", store: userDefaults) private var ignoreFocusFilter: Bool = false
    @AppStorage("adv_overrideRegion", store: userDefaults) private var overrideRegion: String = ""
    @State private var allowReset: Bool = false
    
    var body: some View {
        List {
            Section {
                Button("Reset All Advanced Settings") {
                    disablechecker = false
                    ignoreSafariSettings = false
                    ignoreFocusFilter = false
                    overrideRegion = ""
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
                Toggle(isOn: $ignoreSafariSettings, label: {
                    Text("Ignore Safari Settings")
                })
            } footer: {
                Text("CSE will ignore Safari Settings and detect the URLs of all Safari search engines.")
            }
            
            Section {
                Toggle(isOn: $ignoreFocusFilter, label: {
                    Text("Ignore Focus Filter")
                })
            } footer: {
                Text("CSE will ignore all Focus Filters.")
            }
            
            Section {
                HStack {
                    Text("Override Region")
                    Spacer()
                    TextField(currentRegion ?? "US", text: $overrideRegion)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                        .keyboardType(.asciiCapable)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .scrollToDismissesKeyboard()
                }
            } footer: {
                Text("Overrides the device's region settings when detecting Safari search engines. Blank to disable.")
            }
            
            Section {
                Toggle(isOn: $allowReset, label: {
                    Text("Enable Reset Buttons")
                })
                Button(action: { AppInitializer.resetCSE(target: .defaultCSE) }) {
                    Text("Reset Default Search Engine")
                }
                .disabled(!allowReset)
                Button(action: { AppInitializer.resetCSE(target: .privateCSE) }) {
                    Text("Reset Private Search Engine")
                }
                .disabled(!allowReset)
                Button(action: { AppInitializer.resetCSE(target: .quickCSE) }) {
                    Text("Reset Quick Search Engines")
                }
                .disabled(!allowReset)
                Button(action: { AppInitializer.resetCSE(target: .all) }) {
                    Text("Reset All Custom Search Engines")
                }
                .disabled(!allowReset)
            } footer: { Text("Existing data will be deleted") }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Advanced Settings")
    }
}
