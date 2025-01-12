//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

private func HeaderText(text: String) -> some View {
    Text(text)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 40)
}

private func NextButton(text: String) -> some View {
    Text(text)
        .foregroundColor(.white)
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor)
        .cornerRadius(12)
}

struct FullTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Welcome to CSE")
                
                VStack(spacing: 16) {
                    Text("Before you can start using CSE, you need to do some setup.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                NavigationLink {
                    SafariTutorialView()
                } label: {
                    NextButton(text: "Next")
                }
                .padding(.horizontal, 24)
                Button(action: {
                    dismiss()
                }) {
                    Text("Skip")
                }
                .padding(.bottom, 24)
            }
        }
        .interactiveDismissDisabled()
    }
}

struct SafariTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Safari Settings")
                
                VStack(spacing: 16) {
                    Text("Before you can start using CSE, you need to do some setup.")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    NextButton(text: "Next")
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CreateCSETutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HeaderText(text: "Create your CSE")
                
                VStack(spacing: 16) {
                    Text("")
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    NextButton(text: "Next")
                }
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
