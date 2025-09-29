//
//  SafariWebExtensionHandler.swift
//  Customize Search Engine Extension
//
//  Created by Cizzuk on 2022/07/23.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    let userDefaults = CSEDataManager.userDefaults
    var focusSettings: (cseData: CSEDataManager.CSEData, useQuickCSE: Bool?, useEmojiSearch: Bool?)? = nil
    
    func beginRequest(with context: NSExtensionContext) {
        // Initialize app data and perform necessary updates
        AppInitializer.initializeApp()
        
        // Get Search URL from background.js
        let item = context.inputItems.first as! NSExtensionItem
        guard let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let searchURL: String = message["url"] as? String,
              let isIncognito: Bool = message["incognito"] as? Bool else {
            return sendData(context: context, data: ["type" : "error"])
        }
        
        let searchengine: String = userDefaults.string(forKey: "searchengine") ?? SafariSEs.default.rawValue
        let alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
        let privsearchengine: String = userDefaults.string(forKey: "privsearchengine") ?? SafariSEs.private.rawValue
        let useDefaultCSE: Bool = userDefaults.bool(forKey: "useDefaultCSE")
        let usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
        
        // CSE data set
        struct dataSet: Encodable {
            let type: String
            let redirectTo: String
            let postData: [[String: String]]
        }
        
        Task {
            // Check current focus filter
            try await getFocusFilter()
            
            let searchQuery: String?
            // Get Redirect URL
            if checkEngineURL(engineName: searchengine, url: searchURL) {
                searchQuery = getQueryValue(engineName: searchengine, url: searchURL)
            } else if checkEngineURL(engineName: privsearchengine, url: searchURL) && !alsousepriv {
                searchQuery = getQueryValue(engineName: privsearchengine, url: searchURL)
            } else {
                searchQuery = nil
            }
            
            // Check if searchQuery is available
            guard let query = searchQuery else {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            let redirectData: (type: String, url: String, post: [[String: String]])
            if isIncognito && usePrivateCSE {
                redirectData = makeSearchURL(baseCSE: CSEDataManager.getCSEData(.privateCSE), query: query)
            } else if useDefaultCSE {
                redirectData = makeSearchURL(baseCSE: CSEDataManager.getCSEData(.defaultCSE), query: query)
            } else {
                redirectData = makeSearchURL(baseCSE: CSEDataManager.CSEData(), query: query)
            }
            
            // Check Redirect URL exists
            if redirectData.url.isEmpty {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            // Create CSE Data
            let Data = dataSet(
                type: redirectData.type,
                redirectTo: redirectData.url,
                postData: redirectData.post
            )
            
            // Send to background.js!
            sendData(context: context, data: Data)
        }
    }
    
    func sendData(context: NSExtensionContext, data: Encodable) {
        do {
            let data = try JSONEncoder().encode(data)
            let json = String(data: data, encoding: .utf8)!
            let extensionItem = NSExtensionItem()
            extensionItem.userInfo = [ SFExtensionMessageKey: json ]
            context.completeRequest(returningItems: [extensionItem], completionHandler: nil)
        } catch {
            print("error")
        }
    }
    
    // ↓ --- Search Engine Checker --- ↓

    // Engine Checker
    func checkEngineURL(engineName: String, url: String) -> Bool {
        
        // Is engine available?
        guard let engine = SafariSEs(rawValue: engineName) else {
            return false
        }
        
        // Get engine url
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return false
        }

        // Domain Check
        guard engine.matchesHost(host) else {
            return false
        }

        // Path Check
        let expectedPath = engine.path(for: host)
        guard urlComponents.path.hasPrefix(expectedPath) else {
            return false
        }

        // Get Query
        let queryItems = urlComponents.queryItems ?? []
        
        // Get Param
        let mainParamKey = engine.queryParam(for: host)
        guard queryItems.contains(where: { $0.name == mainParamKey }) else {
            return false
        }
        
        // Param Check
        if !userDefaults.bool(forKey: "adv_disablechecker"),
           let checkParam = engine.checkParameter(for: host) {
            let checkParamKey = checkParam.param
            let possibleIds = checkParam.values
            let checkItemExists = queryItems.contains {
                $0.name == checkParamKey && ( $0.value.map(possibleIds.contains) ?? false )
            }
            guard checkItemExists else { return false }
        }

        // OK
        return true
    }
    
    func getQueryValue(engineName: String, url: String) -> String? {
        // Is engine available?
        guard let engine = SafariSEs(rawValue: engineName) else {
            return nil
        }
        
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host,
              engine.matchesHost(host) else {
            return nil
        }
        
        // Get param name
        let mainParam = engine.queryParam(for: host)
        
        // Get %encoded query
        guard let encodedQuery = urlComponents.percentEncodedQuery else { return nil }
        
        // Split with '&'
        let queryPairs = encodedQuery.components(separatedBy: "&")
        for pair in queryPairs {
            // Split into key and value with '='
            let parts = pair.components(separatedBy: "=")
            if parts.count == 2, parts[0] == mainParam {
                return parts[1]
            }
        }
        
        return nil
    }
    
    func makeSearchURL(baseCSE: CSEDataManager.CSEData, query: String) -> (type: String, url: String, post: [[String: String]]) {
        // --- Description of some Query variables ---
        //  query: %encoding, Full Search Query
        //  decodedQuery: Decoded, Full Search Query
        //  fixedQuery: %encoding, without Quick Search Keyword
        //  decodedFixedQuery: Decoded, without Quick Search Keyword
        //  decodedFixedQueryForPOST: Decoded but + replaced with Space first, without Quick Search Keyword
        
        // Get decoded query
        let decodedQuery: String = query.removingPercentEncoding ?? ""
        
        // Is useEmojiSearch Enabled?
        let useEmojiSearch: Bool
        if let focusUseEmojiSearch = focusSettings?.useEmojiSearch {
            // Set focus filter setting
            useEmojiSearch = focusUseEmojiSearch
        } else {
            useEmojiSearch = userDefaults.bool(forKey: "useEmojiSearch")
        }
        
        // Check Emoji Search
        if useEmojiSearch &&
           decodedQuery.count == 1 &&
           decodedQuery.unicodeScalars.first!.properties.isEmoji &&
           (decodedQuery.unicodeScalars.first!.value >= 0x203C || decodedQuery.unicodeScalars.count > 1) {
            
            // Check Language
            let preferredLanguages = Locale.preferredLanguages
            let emojipediaLangsList: [String] = ["bn", "da", "de", "en", "es", "fr", "hi", "it", "ja", "ko", "mr", "ms", "nl", "no", "pt", "sv", "ta", "te", "zh"]
            var emojipediaLang: String = "en/"
            for language in preferredLanguages {
                let languageCode = language.components(separatedBy: "-").first ?? language
                if emojipediaLangsList.contains(languageCode) {
                    emojipediaLang = languageCode + "/"
                    break
                }
            }
            
            // Make URL
            let redirectURL = "https://emojipedia.org/" + emojipediaLang + query
            return ("redirect", redirectURL, [])
        }
        
        
        // ↓--- if !EmojiSearch ---↓
        
        var fixedQuery: String = query
        
        // Load Settings
        var CSEData: CSEDataManager.CSEData
        if let focusCSE = focusSettings?.cseData {
            // Set focus filter setting
            CSEData = focusCSE
        } else {
            CSEData = baseCSE
        }
        
        // Is useQuickCSE Enabled?
        let useQuickCSE: Bool
        if let focusUseQuickCSE = focusSettings?.useQuickCSE {
            // Set focus filter setting
            useQuickCSE = focusUseQuickCSE
        } else {
            useQuickCSE = userDefaults.bool(forKey: "useQuickCSE")
        }
        
        // Check quick search
        if useQuickCSE {
            // Extract candidate keyword and query
            let beforePlus: String // maybe keyword
            let afterPlus: String? // maybe query
            if let plusRange = query.range(of: "+") {
                beforePlus = String(query[..<plusRange.lowerBound])
                afterPlus = String(query[query.index(after: plusRange.lowerBound)...])
            } else {
                // Maybe keyword only
                beforePlus = query
                afterPlus = nil
            }

            // If keyword only is disabled and there's no '+', skip
            let disableKeywordOnly: Bool = userDefaults.bool(forKey: "adv_disableKeywordOnlyQuickSearch")
            if !disableKeywordOnly || afterPlus != nil {
                let quickCSEData = CSEDataManager.getAllQuickCSEData()
                let candidateKeyword = beforePlus.removingPercentEncoding ?? beforePlus
                if let matched = quickCSEData[candidateKeyword] {
                    fixedQuery = afterPlus ?? ""
                    CSEData = matched
                }
            }
        }
        
        // Get decoded fixedQuery
        var decodedFixedQuery: String = fixedQuery
            .removingPercentEncoding ?? ""
        
        // Get maxQueryLength
        if let maxQueryLength: Int = CSEData.maxQueryLength,
           decodedFixedQuery.count > maxQueryLength {
            decodedFixedQuery = String(decodedFixedQuery.prefix(maxQueryLength))
            fixedQuery = String(fixedQuery.prefix(maxQueryLength))
        }
        
        // Replace %s with query
        let redirectQuery: String = CSEData.disablePercentEncoding ? decodedFixedQuery : fixedQuery
        let redirectURL: String = CSEData.url
            .replacingOccurrences(of: "%s", with: redirectQuery)
        
        // POST
        var postData: [[String: String]] = CSEData.post
        if !postData.isEmpty {
            let decodedFixedQueryForPOST: String = fixedQuery
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            for i in 0..<postData.count {
                postData[i]["key"] = postData[i]["key"]?
                    .replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
                postData[i]["value"] = postData[i]["value"]?
                    .replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
            }
        }
        let redirectType: String = postData.isEmpty ? "redirect" : "postRedirect"
        
        return (redirectType, redirectURL, postData)
    }
    
    // Check current focus filter
    func getFocusFilter() async throws {
        focusSettings = nil
        if userDefaults.bool(forKey: "adv_ignoreFocusFilter") { return }
        do {
            let filter: SetFocusSE = try await SetFocusSE.current
            if filter.useQuickCSE != nil && filter.useEmojiSearch != nil {
                let parsedPost = CSEDataManager.postDataToDictionary(filter.post)
                let focusCSE = CSEDataManager.CSEData(
                    url: filter.cseURL,
                    post: parsedPost,
                    disablePercentEncoding: filter.disablePercentEncoding,
                    maxQueryLength: filter.maxQueryLength
                )
                focusSettings = (focusCSE, useQuickCSE: filter.useQuickCSE, useEmojiSearch: filter.useEmojiSearch)
            }
        }
    }
}

