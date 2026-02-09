//
//  IconChangeView.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2024/09/21.
//

import SwiftUI

struct IconChangeView: View {
    var body: some View {
        List {
            Section {
                iconItem(iconName: "CSE", iconID: "appicon")
                iconItem(iconName: "Red", iconID: "red-white")
                iconItem(iconName: "Green", iconID: "green-white")
                iconItem(iconName: "Mono", iconID: "gray-white")
                iconItem(iconName: "Pride", iconID: "pride")
                iconItem(iconName: "Unity", iconID: "unity")
                iconItem(iconName: "Pixel", iconID: "pixel")
            }
        }
        .navigationTitle("Change App Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func iconItem(iconName: String, iconID: String) -> some View {
        HStack {
            Image(iconID + "-pre")
                .resizable()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)
                .padding(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            Text(iconName)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Change App Icon
            if iconID == "appicon" {
                UIApplication.shared.setAlternateIconName(nil)
            } else {
                UIApplication.shared.setAlternateIconName(iconID)
            }
        }
    }
}
