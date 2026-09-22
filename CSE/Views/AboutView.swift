//
//  AboutView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    UITemplates.IconLabel(icon: "info.circle", text: "Version")
                    Spacer()
                    Text("\(currentVersion ?? "Unknown") (\(currentBuild ?? "Unknown"))")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .accessibilityElement(children: .combine)
                HStack {
                    UITemplates.IconLabel(icon: "hammer", text: "Developer")
                    Spacer()
                    Link(destination: URL(string: "https://cizzuk.net/")!, label: {
                        Text("Cizzuk")
                    })
                }
                Link(destination: URL(string: "https://github.com/Cizzuk/CSE")!, label: {
                    UITemplates.IconLabel(icon: "ladybug", text: "Source")
                })
                Link(destination: URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                    UITemplates.IconLabel(icon: "hand.raised", text: "Privacy Policy")
                })
            } header: {
                Text("Customize Search Engine")
                    .textCase(nil)
            } footer: {
                Link("More About CSE & Privacy...", destination: URL(string: "https://cizz.uk/cse/privacy-report")!)
                    .font(.caption)
                    .padding(.bottom, 20)
            }
            
            Section {} header: {
                Text("License")
            } footer: {
                Text("MIT License\n\nCopyright (c) 2025 Cizzuk\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: \n \nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. \n \nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
                    .environment(\.layoutDirection, .leftToRight)
                    .textSelection(.enabled)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
