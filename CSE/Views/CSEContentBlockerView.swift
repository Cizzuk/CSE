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
            } footer: {
                Link("More details on CSE privacy...", destination: URL(string: "https://cizz.uk/cse/privacy-report")!)
                    .font(.caption)
                    .padding(.vertical, 4)
            }
        }
        .navigationTitle("CSE Content Blocker")
        .navigationBarTitleDisplayMode(.inline)
    }
}
