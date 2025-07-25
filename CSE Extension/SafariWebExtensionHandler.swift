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
        // Get Search URL from content.js
        let item = context.inputItems.first as! NSExtensionItem
        guard let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let searchURL: String = message["url"] as? String,
              let isIncognito: Bool = message["incognito"] as? Bool else {
            return
        }
        
        let searchengine: String = userDefaults.string(forKey: "searchengine") ?? ""
        let alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
        let privsearchengine: String = userDefaults.string(forKey: "privsearchengine") ?? ""
        let usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
        
        var redirectData: (type: String, url: String, post: [[String: String]]) = ("error", "", [])
        
        // CSE data set
        struct dataSet: Encodable {
            let type: String
            let redirectTo: String
            let postData: [[String: String]]
            let adv_ignorePOSTFallback: Bool
        }
        
        Task {
            // Check current focus filter
            try await getFocusFilter()
            
            var searchQuery: String? = nil
            
            // Get Redirect URL
            if checkEngineURL(engineName: searchengine, url: searchURL) {
                searchQuery = getQueryValue(engineName: searchengine, url: searchURL)
            } else if checkEngineURL(engineName: privsearchengine, url: searchURL) && !alsousepriv {
                searchQuery = getQueryValue(engineName: privsearchengine, url: searchURL)
            }
            
            // Check if searchQuery is available
            guard let query = searchQuery else {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            if isIncognito && usePrivateCSE {
                redirectData = makeSearchURL(windowName: "private", query: query)
            } else {
                redirectData = makeSearchURL(windowName: "default", query: query)
            }
            
            // Check Redirect URL exists
            if redirectData.url == "" {
                sendData(context: context, data: ["type" : "cancel"])
                return
            }
            
            // Create CSE Data
            let Data = dataSet(
                type: redirectData.type,
                redirectTo: redirectData.url,
                postData: redirectData.post,
                adv_ignorePOSTFallback: userDefaults.bool(forKey: "adv_ignorePOSTFallback")
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
    
    struct CheckItem {
        let param: String
        let ids: [String]
    }

    struct Engine {
        let domains: [String]
        let path: (String) -> String
        let param: (String) -> String
        let check: ((String) -> CheckItem?)?
    }

    // Safari Default SEs
    let engines: [String: Engine] = [
        "google": Engine(
            domains: ["www.google.com", "www.google.cn"],
            path: { _ in "/search" },
            param: { _ in "q" },
            check: { _ in
                CheckItem(param: "client", ids: ["safari"])
            }
        ),
        "yahoo": Engine(
            domains: ["search.yahoo.com", "search.yahoo.co.jp"],
            path: { _ in "/search" },
            param: { _ in "p" },
            check: { _ in
                CheckItem(param: "fr", ids: ["iphone", "appsfch2", "osx"])
            }
        ),
        "bing": Engine(
            domains: ["www.bing.com"],
            path: { _ in "/search" },
            param: { _ in "q" },
            check: { _ in
                CheckItem(param: "form", ids: ["APIPH1", "APMCS1", "APIPA1"])
            }
        ),
        "duckduckgo": Engine(
            domains: ["duckduckgo.com"],
            path: { _ in "/" },
            param: { _ in "q" },
            check: { _ in
                CheckItem(param: "t", ids: ["iphone", "osx", "ipad"])
            }
        ),
        "ecosia": Engine(
            domains: ["www.ecosia.org"],
            path: { _ in "/search" },
            param: { _ in "q" },
            check: { _ in
                CheckItem(param: "tts", ids: ["st_asaf_iphone", "st_asaf_macos", "st_asaf_ipad"])
            }
        ),
        "baidu": Engine(
            domains: ["m.baidu.com", "www.baidu.com"],
            path: { _ in "/s" },
            param: { domain in
                domain == "m.baidu.com" ? "word" : "wd"
            },
            check: { domain in
                if domain == "m.baidu.com" {
                    return CheckItem(param: "from", ids: ["1000539d"])
                } else {
                    return CheckItem(param: "tn", ids: ["84053098_dg", "84053098_4_dg"])
                }
            }
        ),
        "sogou": Engine(
            domains: ["m.sogou.com", "www.sogou.com"],
            path: { domain in
                domain == "m.sogou.com" ? "/web/sl" : "/web"
            },
            param: { domain in
                domain == "m.sogou.com" ? "keyword" : "query"
            },
            check: nil
        ),
        "360search": Engine(
            domains: ["m.so.com", "www.so.com"],
            path: { _ in "/s" },
            param: { _ in "q" },
            check: nil
        ),
        "yandex": Engine(
            domains: ["yandex.ru"],
            path: { _ in "/search" },
            param: { _ in "text" },
            check: nil
        )
    ]

    // Engine Checker
    func checkEngineURL(engineName: String, url: String) -> Bool {
        
        // Is engine available?
        guard let engine = engines[engineName] else {
            return false
        }
        
        // Get engine url
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return false
        }

        // Domain Check
        guard engine.domains.contains(host) else {
            return false
        }

        // Path Check
        let expectedPath = engine.path(host)
        guard urlComponents.path == expectedPath else {
            return false
        }

        // Get Query
        let queryItems = urlComponents.queryItems ?? []
        
        // Get Param
        let mainParamKey = engine.param(host)
        guard queryItems.contains(where: { $0.name == mainParamKey }) else {
            return false
        }
        
        // Param Check
        if !userDefaults.bool(forKey: "adv_disablechecker"),
           let checkFn = engine.check,
           let checkInfo = checkFn(host) {
            let checkParamKey = checkInfo.param
            let possibleIds = checkInfo.ids
            let checkItemExists = queryItems.contains {
                $0.name == checkParamKey && ( $0.value.map(possibleIds.contains) ?? false )
            }
            guard checkItemExists else {
                return false
            }
        }

        // OK
        return true
    }
    
    func getQueryValue(engineName: String, url: String) -> String? {
        // Is engine available?
        guard let engine = engines[engineName] else {
            return nil
        }
        
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host,
              engine.domains.contains(host) else {
            return nil
        }
        
        // Get param name
        let mainParam = engine.param(host)
        
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
    
    func makeSearchURL(windowName: String, query: String) -> (type: String, url: String, post: [[String: String]]) {
        // --- Description of some Query variables ---
        //  query: %encoding, Full Search Query
        //  decodedQuery: Decoded, Full Search Query
        //  fixedQuery: %encoding, without Quick Search Keyword
        //  decodedFixedQuery: Decoded, without Quick Search Keyword
        //  decodedFixedQueryForPOST: Decoded but + replaced with Space first, without Quick Search Keyword
        
        // Get decoded query
        let decodedQuery: String = query.removingPercentEncoding ?? ""
        
        // Is useEmojiSearch Enabled?
        var useEmojiSearch: Bool = userDefaults.bool(forKey: "useEmojiSearch")
        if focusSettings != nil {
            if focusSettings?.useEmojiSearch == true {
                useEmojiSearch = true
            } else {
                useEmojiSearch = false
            }
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
        var CSEData: CSEDataManager.CSEData = windowName == "private" ?
            CSEDataManager.getCSEData(.privateCSE) :
            CSEDataManager.getCSEData(.defaultCSE)
        
        // Set focus filter setting
        if focusSettings != nil {
            CSEData = focusSettings!.cseData
        }
        
        // Is useQuickCSE Enabled?
        var useQuickCSE: Bool = userDefaults.bool(forKey: "useQuickCSE")
        if focusSettings != nil {
            if focusSettings?.useQuickCSE == true {
                useQuickCSE = true
            } else {
                useQuickCSE = false
            }
        }
        if !(decodedQuery.count > 1 && query.contains("+")) {
            useQuickCSE = false
        }
        
        // Check quick search
        if useQuickCSE {
            var cseID: String
            let quickCSEData = CSEDataManager.getAllQuickCSEData()
            for key in quickCSEData.keys {
                // percent encoded key (all characters including + or &)
                guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(.init(charactersIn: "~-._")))
                else { continue }
                // If query has maybe quick search keyword
                if query.hasPrefix(encodedKey) && (encodedKey.count + 1 < query.count) {
                    let queryNoKey = String(query.dropFirst(encodedKey.count))
                    // If query has space
                    if queryNoKey.hasPrefix("+") {
                        cseID = key
                        fixedQuery = String(queryNoKey.dropFirst(1))
                        CSEData = quickCSEData[cseID] ?? CSEData
                        break
                    }
                }
            }
        }
        
        // Get decoded fixedQuery
        var decodedFixedQuery: String = fixedQuery.removingPercentEncoding ?? ""
        
        // Get maxQueryLength
        if let maxQueryLength: Int = CSEData.maxQueryLength,
           decodedFixedQuery.count > maxQueryLength {
            decodedFixedQuery = String(decodedFixedQuery.prefix(maxQueryLength))
            fixedQuery = String(fixedQuery.prefix(maxQueryLength))
        }
        
        // Replace %s with query
        let redirectQuery: String = CSEData.disablePercentEncoding ? decodedFixedQuery : fixedQuery
        let redirectURL: String = CSEData.url.replacingOccurrences(of: "%s", with: redirectQuery)
        
        // POST
        var postData: [[String: String]] = CSEData.post
        if postData.count > 0 {
            let decodedFixedQueryForPOST: String = fixedQuery.replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? ""
            for i in 0..<postData.count {
                postData[i]["key"] = postData[i]["key"]?.replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
                postData[i]["value"] = postData[i]["value"]?.replacingOccurrences(of: "%s", with: decodedFixedQueryForPOST)
            }
        }
        let redirectType: String = postData.count > 0 ? "haspost" : "redirect"
        
        return (redirectType, redirectURL, postData)
    }
    
    // Check current focus filter
    func getFocusFilter() async throws {
        focusSettings = nil
        if userDefaults.bool(forKey: "adv_ignoreFocusFilter") { return }
        do {
            let filter: SetFocusSE = try await SetFocusSE.current
            if filter.useQuickCSE != nil && filter.useEmojiSearch != nil {
                let focusCSE = CSEDataManager.CSEData(
                    url: filter.cseURL,
                    disablePercentEncoding: filter.disablePercentEncoding,
                    maxQueryLength: filter.maxQueryLength
                )
                focusSettings = (focusCSE, useQuickCSE: filter.useQuickCSE, useEmojiSearch: filter.useEmojiSearch)
            }
        }
    }
}

