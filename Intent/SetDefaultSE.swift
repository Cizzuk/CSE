//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents
#if !os(visionOS)
import WidgetKit
#endif

struct SetDefaultSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "SetDefaultSE"
    static var title: LocalizedStringResource = "Set Default Search Engine"
    static var description: LocalizedStringResource = "Sets a Custom Default Search Engine on CSE."

    @Parameter(title: "URL", description: "Blank to disable", default: "")
        var cseURL: String
    
    @Parameter(title: "POST Data", description: "Blank to disable", default: "")
        var post: String
    
    @Parameter(title: "Disable Percent-encoding", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Blank to disable", default: nil)
        var maxQueryLength: Int?

    func perform() async throws -> some IntentResult {
        let userDefaults = CSEDataManager.userDefaults
        if cseURL.isEmpty {
            userDefaults.set(false, forKey: "useDefaultCSE")
        } else {
            userDefaults.set(true, forKey: "useDefaultCSE")
        }
        #if !os(visionOS)
        if #available(iOS 18.0, macOS 26, *) {
            ControlCenter.shared.reloadControls(ofKind: "com.tsg0o0.cse.CCWidget.UseDefaultCSE")
        }
        #endif
        
        let parsedPost = CSEDataManager.postDataToDictionary(post)
        
        let cseData = CSEDataManager.CSEData(
            url: cseURL,
            post: parsedPost,
            disablePercentEncoding: disablePercentEncoding,
            maxQueryLength: maxQueryLength
        )
        
        CSEDataManager.saveCSEData(cseData, .defaultCSE)
        
        return .result()
    }
}
