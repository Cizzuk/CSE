//
//  WidgetExtensionBundle.swift
//  CSE Widget Extension
//
//  Created by Cizzuk on 2025/05/26.
//

import SwiftUI
import WidgetKit

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        CCUseDefaultCSE()
        CCUsePrivateCSE()
        CCQuickSearch()
        CCEmojiSearch()
    }
}
