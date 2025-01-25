//
//  SetFocusSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import AppIntents

@available(iOS 16.0, macOS 13.0, *)
struct SetFocusSE : SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Set Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Search Engine to be used during this Focus."
    
    @Parameter(title: "URL", description: "Replace query with %s", default: nil)
    var cseURL: String?
    
    @Parameter(title: "Quick Search", default: nil)
    var useQuickCSE: Bool?
    
    @Parameter(title: "Emoji Search", default: nil)
    var useEmojiSearch: Bool?
    
    var displayRepresentation: DisplayRepresentation {
        var subtitleList: [String] = []
        
        if self.cseURL == "" || self.cseURL == nil {
            if useQuickCSE ?? false {
                subtitleList.append("Quick Search")
            }
            if useEmojiSearch ?? false {
                subtitleList.append("Emoji Search")
            }
            if subtitleList.count == 0 {
                subtitleList.append("Disable CSE")
            }
        } else {
            subtitleList.append(self.cseURL!)
        }
        
        let subtitle = LocalizedStringResource("\(subtitleList.formatted())")
        return DisplayRepresentation(title: SetFocusSE.title, subtitle: subtitle)
    }
    
    
    func perform() async throws -> some IntentResult {

        return .result()
    }
}
