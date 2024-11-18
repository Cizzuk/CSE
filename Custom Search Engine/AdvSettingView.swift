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
    @AppStorage("adv_redirectat", store: UserDefaults(suiteName: "group.com.tsg0o0.cse"))
    var redirectat: String = UserDefaults(suiteName: "group.com.tsg0o0.cse")!.string(forKey: "adv_redirectat") ?? "loading"
    //loading, interactive, complete
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("adv_resetall") {
                        userDefaults!.set(false, forKey: "adv_disablechecker")
                        userDefaults!.set("loading", forKey: "adv_redirectat")
                    }
                }
                Section {
                    Toggle(isOn: $disablechecker, label: {
                        Text("adv_disablechecker")
                    })
                    .onChange(of: disablechecker) { newValue in
                        userDefaults!.set(newValue, forKey: "adv_disablechecker")
                    }
                } footer: {
                    Text("adv_disablechecker-Desc-1")
                }
                Section {
                    Picker("adv_redirectat", selection: $redirectat) {
                        Text("loading").tag("loading")
                        Text("interactive").tag("interactive")
                        Text("complete").tag("complete")
                    }
                    .onChange(of: redirectat) { entered in
                        userDefaults!.set(entered, forKey: "adv_redirectat")
                    }
                } footer: {
                    Text("adv_redirectat-Desc-1")
                }
            }
        }
    }
}
