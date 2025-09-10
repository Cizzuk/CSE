//
//  CCWidgetBundle.swift
//  CSE CCWidget
//
//  Created by Cizzuk on 2025/05/26.
//

import WidgetKit
import SwiftUI

@main
struct CCWidgetBundle: WidgetBundle {
    var body: some Widget {
        CCUseDefaultCSE()
        CCUsePrivateCSE()
        CCQuickSearch()
        CCEmojiSearch()
    }
}
