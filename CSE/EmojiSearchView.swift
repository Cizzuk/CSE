//
//  EmojiSearchView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/24.
//

import SwiftUI
#if !os(visionOS)
import WidgetKit
#endif

struct EmojiSearchView: View {
    @AppStorage("useEmojiSearch", store: userDefaults) private var useEmojiSearch: Bool = false
    
    var body: some View {
        List {
            Section {
                // Emoji Search Setting
                Toggle(isOn: $useEmojiSearch) {
                    Text("Emoji Search")
                }
                #if !os(visionOS)
                .onChange(of: useEmojiSearch) { _ in
                    if #available(iOS 18.0, macOS 26, *) {
                        ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.EmojiSearch")
                    }
                }
                #endif
            } footer: {
                Text("If you enter only one emoji, you can search on Emojipedia.org.")
            }
            
            Section {} footer: {
                VStack(alignment: .leading) {
                    Text("If you use this feature, you need to agree to the terms of service and privacy policy of Emojipedia.")
                    Spacer()
                    Link("Emojipedia Terms of Service...", destination: URL(string: "https://emojipedia.org/tos")!)
                    Spacer()
                    Link("Emojipedia Privacy Policy...", destination: URL(string: "https://emojipedia.org/privacy-policy")!)
                }
                .font(.caption)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Emoji Search")
    }
}
