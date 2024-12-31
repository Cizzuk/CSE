//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        @Environment(\.dismiss) var dismiss
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")
        VStack(spacing: 16) {
            // Title
            Text("Welcome to CSE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                Text("Before using CSE, do some setup.")
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button(action: {
                
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            Button(action: {
                dismiss()
            }) {
                Text("Skip")
            }
            .padding(.bottom, 24)
        }
        .interactiveDismissDisabled()
    }
}
