//
//  TutorialViews+Welcome.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/12/31.
//

import SwiftUI

extension TutorialViews {
    struct WelcomeView: View {
        @Binding var isOpenSheet: Bool
        @State private var isNavigation: Bool = false
        
        var body: some View {
            List {
                UITemplates.HeaderSection(
                    title: "Welcome to CSE",
                    description: "Before you can start using CSE, you need to do some setup."
                )
                
                Section {
                    HStack {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)
                            .foregroundStyle(.accent)
                            .padding(6)
                        Text("Enable Extension in Safari")
                            .font(.headline)
                    }
                    HStack {
                        Image(systemName: "sparkle.magnifyingglass")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)
                            .foregroundStyle(.accent)
                            .padding(6)
                        Text("Setup Custom Search Engine")
                            .font(.headline)
                    }
                    HStack {
                        Image(systemName: "safari")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)
                            .foregroundStyle(.accent)
                            .padding(6)
                        Text("Enjoy your Search Life!")
                            .font(.headline)
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigation) {
                SafariSEView(isOpenSheet: $isOpenSheet, isFirstTutorial: true)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    UITemplates.TutorialButton(action: { isNavigation = true }, text: "Next")
                }
            }
            #if !os(visionOS)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            #endif
            .interactiveDismissDisabled()
        }
    }
}
