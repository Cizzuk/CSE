//
//  SetPrivateSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents
#if !os(visionOS)
import WidgetKit
#endif

struct SetPrivateSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetPrivateSE"
    static var title: LocalizedStringResource = "Set Private Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Private Search Engine on CSE."
    
    @Parameter(title: "URL", description: "Blank to disable", default: "")
        var cseURL: String
    
    @Parameter(title: "Space Character", description: "Use a specific character as the query separator. Default is +.", default: "+")
        var spaceCharacter: String
    
    @Parameter(title: "Disable Percent-encoding", description: "Disable percent-encoding of queries. When enabled, some symbols and non-ASCII characters may become unavailable.", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Truncate the query to the specified character count. Blank to disable.", default: nil)
        var maxQueryLength: Int?
    
    @Parameter(title: "POST Data", description: "Not Recommended. Search using POST request. Blank to disable.", default: "")
        var post: String

    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        if cseURL.isEmpty {
            userDefaults.set(false, forKey: "usePrivateCSE")
        } else {
            userDefaults.set(true, forKey: "usePrivateCSE")
        }
        #if !os(visionOS)
        if #available(iOS 18.0, macOS 26, *) {
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UsePrivateCSE")
        }
        #endif
        
        let parsedPost = CSEDataManager.postDataToDictionary(post)
        
        let cseData = CSEDataManager.CSEData(
            url: cseURL,
            post: parsedPost,
            spaceCharacter: spaceCharacter,
            disablePercentEncoding: disablePercentEncoding,
            maxQueryLength: maxQueryLength
        )
        
        CSEDataManager.saveCSEData(cseData, .privateCSE)
        
        return .result()
    }
}
