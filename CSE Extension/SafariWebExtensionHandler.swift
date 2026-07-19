//
//  SafariWebExtensionHandler.swift
//  Customize Search Engine Extension
//
//  Created by Cizzuk on 2022/07/23.
//

import SafariServices
import os.log

final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    let userDefaults = CSEDataManager.userDefaults
    var focusSettings: (cseData: CSEDataManager.CSEData, useQuickCSE: Bool?, useEmojiSearch: Bool?)? = nil
    
    enum RedirectType: String, Encodable {
        case redirect
        case postRedirect
    }
    
    struct SendDataSet: Encodable {
        let type: RedirectType
        let redirectTo: String
        let postData: [[String: String]]
    }
    
    func beginRequest(with context: NSExtensionContext) {
        // Initialize app data and perform necessary updates
        AppInitializer.initializeApp()
        
        // Get Search URL from background.js
        let item = context.inputItems.first as! NSExtensionItem
        guard let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let searchURL: String = message["url"] as? String else {
            return sendData(context: context, data: ["type" : "error"])
        }
        
        // Check if Private CSE should be used
        let usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
        let incognitoFlag = message["incognito"] as? Bool
        let shouldUsePrivateCSE = usePrivateCSE && (incognitoFlag ?? false)
        
        // MARK: Get App Settings
        
        // Get Safari Search Engine Settings
        let safariSE: SafariSEs
        if let rawValue = userDefaults.string(forKey: "searchengine"),
           let candidate = SafariSEs(rawValue: rawValue),
           candidate.isAvailable {
            safariSE = candidate
        } else {
            safariSE = .default
        }
        
        // Private
        let safariAlsoUsePrivate: Bool = userDefaults.bool(forKey: "alsousepriv")
        let safariSEPrivate: SafariSEs
        if let rawValue = userDefaults.string(forKey: "privsearchengine"),
           let candidate = SafariSEs(rawValue: rawValue),
           candidate.isAvailable {
            safariSEPrivate = candidate
        } else {
            safariSEPrivate = .private
        }
        
        // Get advanced settings
        let adv_disablechecker = userDefaults.bool(forKey: "adv_disablechecker")
        let adv_ignoreSafariSettings = userDefaults.bool(forKey: "adv_ignoreSafariSettings")
        
        // Support function
        func engineIsMatchedURL(_ engine: SafariSEs, _ url: String) -> Bool {
            return engine.isMatchedURL(url, disableChecker: adv_disablechecker)
        }
        
        Task {
            // Check current Focus Filter
            try? await getFocusFilter()
            
            var searchQuery: String?
            var chechedEngines: [SafariSEs] = []
            
            // Get search query from user selected safari engines
            if engineIsMatchedURL(safariSE, searchURL) {
                searchQuery = safariSE.getQuery(from: searchURL)
                chechedEngines.append(safariSE)
            } else if safariAlsoUsePrivate && engineIsMatchedURL(safariSEPrivate, searchURL) {
                searchQuery = safariSEPrivate.getQuery(from: searchURL)
                chechedEngines.append(safariSEPrivate)
            }
            
            // If adv_ignoreSafariSettings is enabled and searchQuery is nil, check all available engines
            if adv_ignoreSafariSettings && searchQuery == nil {
                for engine in SafariSEs.availableEngines {
                    // Skip already checked engines
                    if chechedEngines.contains(engine) { continue }
                    // Check engine
                    if engineIsMatchedURL(engine, searchURL) {
                        searchQuery = engine.getQuery(from: searchURL)
                        break
                    }
                }
            }
            
            // If all search engines are not matched, return cancel
            guard let searchQuery else {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            // Fixed a macOS Safari bug where full-width spaces are not replaced with '+'
            let fixedQuery = searchQuery
                .replacingOccurrences(of: "%E3%80%80", with: "+", options: .caseInsensitive)
                .replacingOccurrences(of: "%20", with: "+", options: .caseInsensitive)
                .replacingOccurrences(of: "　", with: "+")
                .replacingOccurrences(of: " ", with: "+")
            
            // Create Redirect Data
            let redirectData = makeSearchURL(shouldUsePrivateCSE: shouldUsePrivateCSE, query: fixedQuery)
            
            // If redirect URL is empty, return cancel
            guard !redirectData.redirectTo.isEmpty else {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            // Send to background.js!
            sendData(context: context, data: redirectData)
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
    
    // MARK: - Make Search URL
    func makeSearchURL(shouldUsePrivateCSE: Bool, query: String) -> SendDataSet {
        // --- Description of some Query variables ---
        //  query: %encoding, Full Search Query
        //  decodedQuery: Decoded, Full Search Query
        //  fixedQuery: %encoding, without Quick Search Keyword
        //  decodedFixedQuery: Decoded, without Quick Search Keyword
        //  decodedFixedQueryForPOST: Decoded but + replaced with Space first, without Quick Search Keyword
        
        // Get decoded query
        let decodedQuery: String = query.removingPercentEncoding ?? ""
        
        // MARK: - Emoji Search
        
        // Is useEmojiSearch Enabled?
        let useEmojiSearch: Bool
        if let focusUseEmojiSearch = focusSettings?.useEmojiSearch {
            useEmojiSearch = focusUseEmojiSearch
        } else {
            useEmojiSearch = userDefaults.bool(forKey: "useEmojiSearch")
        }
        
        // If Emoji Search
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
            
            return SendDataSet(
                type: .redirect,
                redirectTo: redirectURL,
                postData: [],
            )
        }
        
        // MARK: End of Emoji Search
        
        // Prepare CSEData
        var CSEData: CSEDataManager.CSEData?
        var fixedQuery: String = query
        
        // MARK: - Quick Search
        
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
        
        // MARK: End of Quick Search
        
        // MARK: - Determine CSEData to Use
        
        // If CSEData is nil (is not Quick Search), get Focus, Default or Private CSE
        if CSEData == nil {
            if let focusCSE = focusSettings?.cseData {
                // Set focus filter setting
                CSEData = focusCSE
            } else if shouldUsePrivateCSE {
                CSEData = CSEDataManager.getCSEData(.privateCSE)
            } else {
                CSEData = CSEDataManager.getCSEData(.defaultCSE)
            }
        }
        
        // If CSEData is still nil, return empty redirect
        guard let CSEData else {
            return SendDataSet(
                type: .redirect,
                redirectTo: "",
                postData: [],
            )
        }
        
        // MARK: - Prepare Redirect
        
        // Get decoded fixedQuery
        var decodedFixedQuery: String = fixedQuery
            .removingPercentEncoding ?? ""
        
        // Get maxQueryLength
        if let maxQueryLength: Int = CSEData.maxQueryLength,
           decodedFixedQuery.count > maxQueryLength {
            decodedFixedQuery = String(decodedFixedQuery.prefix(maxQueryLength))
            fixedQuery = String(decodedFixedQuery.prefix(maxQueryLength)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
        
        // Replace Space Character
        if CSEData.spaceCharacter != "+" {
            fixedQuery = fixedQuery
                .replacingOccurrences(of: "+", with: CSEData.spaceCharacter)
            decodedFixedQuery = decodedFixedQuery
                .replacingOccurrences(of: "+", with: CSEData.spaceCharacter)
        }
        
        // Replace %s with query
        let redirectQuery: String = CSEData.disablePercentEncoding ? decodedFixedQuery : fixedQuery
        let redirectURL: String = CSEData.url
            .replacingOccurrences(of: "%s", with: redirectQuery)
        
        // MARK: POST
        var postData: [[String: String]] = CSEData.post
        if !postData.isEmpty {
            var decodedFixedQueryForPOST: String
            
            // Disable Percent-encoding
            if CSEData.disablePercentEncoding {
                decodedFixedQueryForPOST = decodedFixedQuery
            } else {
                decodedFixedQueryForPOST = fixedQuery
            }
            
            if CSEData.spaceCharacter == "+" {
                // Replace + with Space for POST
                decodedFixedQueryForPOST = decodedFixedQueryForPOST
                    .replacingOccurrences(of: "+", with: " ")
            }
            
            for i in 0..<postData.count {
                postData[i]["key"] = postData[i]["key"]?
                    .replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
                postData[i]["value"] = postData[i]["value"]?
                    .replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
            }
        }
        
        // MARK: End of Prepare Redirect
        
        let redirectType: RedirectType = postData.isEmpty ? .redirect : .postRedirect
        
        return SendDataSet(
            type: redirectType,
            redirectTo: redirectURL,
            postData: postData,
        )
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
