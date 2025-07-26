//
//  AboutView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/24.
//

import SwiftUI

struct AboutView: View {
    #if iOS
    let buildScheme = "iOS"
    #elseif macOS
    let buildScheme = "macOS"
    #elseif visionOS
    let buildScheme = "visionOS"
    #else
    let buildScheme = "Unknown"
    #endif
    
    var body: some View {
        List {
            Section {
                Text("Customize Search Engine")
                    .textSelection(.enabled)
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(currentVersion ?? "Unknown") (\(buildScheme) / \(currentBuild ?? "Unknown"))")
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Text("Developer")
                    Spacer()
                    Link(destination:URL(string: "https://cizzuk.net/")!, label: {
                        Text("Cizzuk")
                    })
                }
            }
            
            Section {} header: {
                Text("License")
            } footer: {
                Text("MIT License\n\nCopyright (c) 2025 Cizzuk\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE.")
                    .environment(\.layoutDirection, .leftToRight)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
