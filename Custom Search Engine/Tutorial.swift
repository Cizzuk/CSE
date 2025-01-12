//
//  Tutorial.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

struct FullTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
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
                NavigationLink {
                    SafariTutorialView()
                } label: {
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
        }
        .interactiveDismissDisabled()
    }
}

struct SafariTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title
                Text("Safari Settings")
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
                // Title
                Text("Create your CSE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Text("")
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
                .padding([.horizontal, .bottom], 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
