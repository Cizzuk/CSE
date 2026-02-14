//
//  CSEContentBlockerView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2026/02/14.
//

import SwiftUI

struct CSEContentBlockerView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 5) {
                    Image("cse-content-blocker")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .accessibilityHidden(true)
                        .padding(.bottom, 10)
                    Text("CSE Content Blocker")
                        .font(.title2)
                        .bold()
                    Text("This is an additional extension that blocks Safari's search engine to prevent leaks of your search queries.")
                        .foregroundColor(.secondary)
                }
                
                // Open Settings Button
                UITemplates.OpenSettingsButton()
            }
        }
        .navigationTitle("CSE Content Blocker")
        .navigationBarTitleDisplayMode(.inline)
    }
}
