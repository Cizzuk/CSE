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
              let searchURL: String = message["url"] as? String else {
            return sendData(context: context, data: ["type" : "error"])
        }
        
        let useDefaultCSE: Bool = userDefaults.bool(forKey: "useDefaultCSE")
        let usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
        
        // Check Incognito Status
        let incognitoFlag = message["incognito"] as? Bool
        if usePrivateCSE && incognitoFlag == nil {
            return sendData(context: context, data: ["type" : "needIncognitoStatus"])
        }
        let isIncognito = usePrivateCSE && (incognitoFlag ?? false)
        
        // Safari Search Engine
        let searchengine: SafariSEs
        if let rawValue = userDefaults.string(forKey: "searchengine"),
           let candidate = SafariSEs(rawValue: rawValue),
           candidate.isAvailable {
            searchengine = candidate
        } else {
            searchengine = .default
        }
        
        // Safari Private Search Engine
        let alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
        let privsearchengine: SafariSEs
        if let rawValue = userDefaults.string(forKey: "privsearchengine"),
           let candidate = SafariSEs(rawValue: rawValue),
           candidate.isAvailable {
            privsearchengine = candidate
        } else {
            privsearchengine = .private
        }
        
        // CSE data set
        struct dataSet: Encodable {
            let type: String
            let redirectTo: String
            let postData: [[String: String]]
        }
        
        Task {
            // Check current focus filter
            try await getFocusFilter()
            
            var searchQuery: String? = nil
            
            // Get search query from user selected engines
            if checkEngineURL(engine: searchengine, url: searchURL) {
                searchQuery = getQueryValue(engine: searchengine, url: searchURL)
            } else if !alsousepriv && checkEngineURL(engine: privsearchengine, url: searchURL) {
                searchQuery = getQueryValue(engine: privsearchengine, url: searchURL)
            }
            
            // If adv_ignoreSafariSettings and not matched, try all other available engines
            let adv_ignoreSafariSettings = userDefaults.bool(forKey: "adv_ignoreSafariSettings")
            if adv_ignoreSafariSettings && searchQuery == nil {
                for engine in SafariSEs.availableEngines {
                    // Skip already checked engines
                    if engine == searchengine || (!alsousepriv && engine == privsearchengine) {
                        continue
                    }
                    if checkEngineURL(engine: engine, url: searchURL) {
                        searchQuery = getQueryValue(engine: engine, url: searchURL)
                        break
                    }
                }
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
        } catch {}
    }
    
    // MARK: - SafariSEs Support

    // Engine Checker
    func checkEngineURL(engine: SafariSEs, url: String) -> Bool {
        guard !userDefaults.bool(forKey: "adv_disablechecker") else {
            return true
        }
        
        return engine.isMatchedURL(url)
    }
    
    func getQueryValue(engine: SafariSEs, url: String) -> String? {
        return engine.getQuery(from: url)
    }
    
    // MARK: - Make Search URL
    
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
            // Get Quick Search Settings
            let keywordOnly: Bool = userDefaults.bool(forKey: "QuickSearchSettings_keywordOnly")
            let keywordPosRaw = userDefaults.string(forKey: "QuickSearchSettings_keywordPos")
            let keywordPos = QuickSearchKeywordPos(rawValue: keywordPosRaw ?? QuickSearchKeywordPos.default.rawValue) ?? .default
            let quickCSEData = CSEDataManager.getAllQuickCSEData()

            // Split query into components with '+'
            var components = query
                .split(separator: "+", omittingEmptySubsequences: false)
                .map(String.init)
            if components.isEmpty {
                components = [query]
            }
            let decodedComponents = components.map { $0.removingPercentEncoding ?? $0 }

            // Apply Matched Quick Search
            func applyMatch(_ matchedData: CSEDataManager.CSEData, removing indices: Set<Int>) {
                // Remove keyword from query
                let remaining = components.enumerated()
                    .filter { !indices.contains($0.offset) }
                    .map { $0.element }
                fixedQuery = remaining.joined(separator: "+")
                // Set CSEData
                CSEData = matchedData
            }

            // Match Checking
            // Check keyword only quick search
            if keywordOnly && components.count == 1 {
                let candidate = decodedComponents[0]
                if let matched = quickCSEData[candidate] {
                    applyMatch(matched, removing: Set([0]))
                }
            } else if components.count > 1 {
                switch keywordPos {
                case .prefix:
                    if let first = decodedComponents.first,
                       let matched = quickCSEData[first] {
                        applyMatch(matched, removing: Set([0]))
                    }
                case .suffix:
                    if let lastIndex = decodedComponents.indices.last {
                        let keyword = decodedComponents[lastIndex]
                        if let matched = quickCSEData[keyword] {
                            applyMatch(matched, removing: Set([lastIndex]))
                        }
                    }
                case .prefORsuf:
                    if let first = decodedComponents.first,
                       let matched = quickCSEData[first] {
                        applyMatch(matched, removing: Set([0]))
                    } else if let lastIndex = decodedComponents.indices.last {
                        let keyword = decodedComponents[lastIndex]
                        if let matched = quickCSEData[keyword] {
                            applyMatch(matched, removing: Set([lastIndex]))
                        }
                    }
                case .prefANDsuf:
                    if decodedComponents.count >= 2 {
                        let first = decodedComponents.first!
                        let lastIndex = decodedComponents.count - 1
                        if first == decodedComponents[lastIndex],
                           let matched = quickCSEData[first] {
                            applyMatch(matched, removing: Set([0, lastIndex]))
                        }
                    }
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
    
    // MARK: - Focus Filter Support
    
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

