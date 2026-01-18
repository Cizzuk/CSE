//
//  SetDefaultSE.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/01/24.
//

import Foundation
import AppIntents

struct AddQuickSE: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "AddQuickSE"
    static var title: LocalizedStringResource = "Add Quick Search Engine"
    static var description: LocalizedStringResource = "Adds a Custom Quick Search Engine on CSE."
    
    @Parameter(title: "Replace", description: "If the keyword is already in use, replace and save", default: false)
        var replace: Bool
    
    @Parameter(title: "Name", default: "")
        var name: String
    
    @Parameter(title: "Keyword")
        var cseID: String
    
    @Parameter(title: "URL")
        var cseURL: String
    
    @Parameter(title: "Space Character", description: "Use a specific character as the query separator. Default is +.", default: "+")
        var spaceCharacter: String
    
    @Parameter(title: "Disable Percent-encoding", description: "Disable percent-encoding of queries. When enabled, some symbols and non-ASCII characters may become unavailable.", default: false)
        var disablePercentEncoding: Bool
    
    @Parameter(title: "Max Query Length", description: "Truncate the query to the specified character count. Blank to disable.", default: nil)
        var maxQueryLength: Int?
    
    @Parameter(title: "POST Data", description: "Not Recommended. Search using POST request. Blank to disable.", default: "")
        var post: String

    func perform() async throws -> some IntentResult & ReturnsValue<String?> {
        let parsedPost = CSEDataManager.postDataToDictionary(post)
        
        let cseData = CSEDataManager.CSEData(
            name: name,
            keyword: cseID,
            url: cseURL,
            post: parsedPost,
            spaceCharacter: spaceCharacter,
            disablePercentEncoding: disablePercentEncoding,
            maxQueryLength: maxQueryLength
        )
        
        do {
            try CSEDataManager.saveCSEData(cseData, nil, replace: replace)
        } catch let error as CSEDataManager.saveCSEDataError {
            throw error
        }
        
        return .result(value: nil)
    }
}
