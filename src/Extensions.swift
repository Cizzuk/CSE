//
//  Extensions.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/07/24.
//

import SwiftUI

// View extensions for common styling
extension View {
    func scrollToDismissesKeyboard() -> some View {
        self
            #if !os(visionOS)
            .scrollDismissesKeyboard(.interactively)
            #endif
    }
    
    // Glass effect button for tutorial
    func glassEffectTutorialButton() -> some View {
        if #available(iOS 26, macOS 26, *) {
            #if !os(visionOS)
            return AnyView(self.glassEffect(.regular.tint(.accentColor).interactive()))
            #else
            return AnyView(self)
            #endif
        } else {
            return AnyView(self)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(16)
        }
    }
}

