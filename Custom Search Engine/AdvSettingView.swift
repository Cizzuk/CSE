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
    //loading, interactive, complete
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Reset All Advanced Settings") {
                        userDefaults!.set(false, forKey: "adv_disablechecker")
                    }
                }
                Section {
                    Toggle(isOn: $disablechecker, label: {
                        Text("Disable Checker")
                    })
                    .onChange(of: disablechecker) { newValue in
                        userDefaults!.set(newValue, forKey: "adv_disablechecker")
                    }
                } footer: {
                    Text("CSE will not check that you have searched from the search bar.")
                }
            }
        }
    }
}
