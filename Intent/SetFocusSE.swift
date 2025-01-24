//
//  SetFocusSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SetFocusSE : SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Set Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Search Engine to be used during this Focus."
    
    typealias IntentPerformResultType = IntentResult
    
    @Parameter(title: "URL", description: "Replace query with %s")
    var cseURL: String?
    
    @Parameter(title: "Enable Quick Search", default: false)
    var useQuickCSE: Bool?
    
    @Parameter(title: "Enable Emoji Search", default: false)
    var useEmojiCSE: Bool?
    
    var displayRepresentation: DisplayRepresentation {
        var subtitleList: [String] = []
        var subtitle: LocalizedStringResource
        
        if let cseURL = self.cseURL {
            subtitleList.append(cseURL)
            subtitle = LocalizedStringResource("\(subtitleList.formatted())")
        } else {
            subtitle = LocalizedStringResource("Disable CSE")
        }
        
        return DisplayRepresentation(title: SetFocusSE.title, subtitle: subtitle)
    }
    
    
    func perform() async throws -> some IntentPerformResultType {
        

        return .result()
    }
    
    
}
