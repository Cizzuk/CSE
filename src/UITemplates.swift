//
//  UITemplates.swift
//  CSE
//
//  Created by Cizzuk on 2025/05/25.
//

import SwiftUI

class UITemplates {
    struct IconLabel: View {
        @Environment(\.dynamicTypeSize) var dynamicTypeSize
        
        let icon: String
        let text: String.LocalizationValue
        
        var body: some View {
            HStack {
                if dynamicTypeSize <= .xxxLarge {
                    Image(systemName: icon)
                        .frame(width: 20.0, alignment: .center)
                    Spacer().frame(width: 10.0)
                }
                Text(String(localized: text))
            }
        }
    }
    
    struct RecommendedSEButton: View {
        let action: () -> Void
        let cse: CSEDataManager.CSEData
        
        var body: some View {
            Button {
                action()
            } label: {
                VStack(alignment: .leading) {
                    Text(cse.name)
                        .bold()
                    Text(cse.url)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .accessibilityLabel(cse.name)
            .foregroundColor(.primary)
        }
    }
    
    struct HeaderSection: View {
        let title: String.LocalizationValue
        let description: String.LocalizationValue
        
        var body: some View {
            Section {}
            header: {
                Text(String(localized: title))
                    .textCase(.none)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
            }
            footer: {
                Text(String(localized: description))
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)
            }
        }
    }
    
    struct TutorialButton: View {
        let action: () -> Void
        let text: String.LocalizationValue
        
        var body: some View {
            GeometryReader { geo in
                Button(action: action) {
                    Text(String(localized: text))
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        .bold()
                        .padding()
                        #if !os(visionOS)
                        .foregroundColor(.white)
                        #endif
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .glassEffectTutorialButton()
            }
            .frame(maxWidth: .infinity, minHeight: 40)
        }
    }
    
    struct OpenSettingsButton: View {
        var body: some View {
            #if !targetEnvironment(macCatalyst)
            // Open Safari Settings Button
            Button(action: {
                if let url = URL(string: "App-Prefs:com.apple.mobilesafari") {
                    UIApplication.shared.open(url)
                }
            }) {
                UITemplates.IconLabel(icon: "gear", text: "Open Settings")
                    #if !os(visionOS)
                    .foregroundColor(.accentColor)
                    #endif
            }
            #endif
        }
    }
}
