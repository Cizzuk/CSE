//
//  SetFocusSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import AppIntents

struct SetFocusSE : SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Set Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Search Engine to be used during this Focus."
    
    @Parameter(title: "URL", description: "Blank to disable CSE", default: "")
        var cseURL: String
    
    @Parameter(title: "POST Data", description: "Blank to disable", default: "")
        var post: String
    
    @Parameter(title: "Disable Percent-encoding", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Blank to disable", default: nil)
        var maxQueryLength: Int?
    
    @Parameter(title: "Quick Search", default: nil)
        var useQuickCSE: Bool?
    
    @Parameter(title: "Emoji Search", default: nil)
        var useEmojiSearch: Bool?
    
    var displayRepresentation: DisplayRepresentation {
        let subtitle: LocalizedStringResource
        
        if self.cseURL.isEmpty {
            if useQuickCSE ?? false || useEmojiSearch ?? false {
                subtitle = LocalizedStringResource("Disable Default Search Engine")
            } else {
                subtitle = LocalizedStringResource("Disable CSE")
            }
        } else {
            // cut prefix http:// or https:// from URL for display
            let displayURL: String
            if cseURL.hasPrefix("http://") {
                displayURL = String(cseURL.dropFirst(7))
            } else if cseURL.hasPrefix("https://") {
                displayURL = String(cseURL.dropFirst(8))
            } else {
                displayURL = cseURL
            }
            subtitle = LocalizedStringResource("\(displayURL)")
        }
        
        return DisplayRepresentation(title: SetFocusSE.title, subtitle: subtitle)
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
