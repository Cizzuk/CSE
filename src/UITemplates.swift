//
//  UITemplates.swift
//  CSE
//
//  Created by Cizzuk on 2025/05/25.
//

import SwiftUI

class UITemplates {
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
    
    struct TutorialButton: View {
        let text: String.LocalizationValue
        
        var body: some View {
            Text(String(localized: text))
                .font(.headline)
                .padding()
                #if !os(visionOS)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .glassEffectTutorialButton()
                #endif
        }
    }
    
    struct IconLabel: View {
        let icon: String
        let text: String.LocalizationValue
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20.0)
                Spacer().frame(width: 10.0)
                Text(String(localized: text))
            }
        }
    }
}
