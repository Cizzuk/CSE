//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var requestTutorial: [String]
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Welcome to CSE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                Text("Before you can start using CSE, you need to do some setup.")
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
