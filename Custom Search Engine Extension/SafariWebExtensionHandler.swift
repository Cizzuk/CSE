//
//  SafariWebExtensionHandler.swift
//  Customize Search Engine Extension
//
//  Created by Cizzuk on 2022/07/23.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    func beginRequest(with context: NSExtensionContext) {
        // Get Search URL from content.js
        let item = context.inputItems.first as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any]
        guard let searchURL = message?["url"] as? String else {
            return
        }
        
        let searchengine: String = userDefaults.string(forKey: "searchengine") ?? ""
        let alsousepriv: Bool = userDefaults.bool(forKey: "alsousepriv")
        let privsearchengine: String = userDefaults.string(forKey: "privsearchengine") ?? ""
        let usePrivateCSE: Bool = userDefaults.bool(forKey: "usePrivateCSE")
        
        var redirectData: (url: String, post: [[String: String]])
        
        // Get Redirect URL
        if checkEngineURL(engineName: searchengine, url: searchURL) {
            guard let searchQuery: String = getQueryValue(engineName: searchengine, url: searchURL) else {
                sendData(context: context, data: ["type" : "error"])
                return
            }
            redirectData = makeSearchURL(windowName: "default", query: searchQuery)
        } else if usePrivateCSE && !alsousepriv && checkEngineURL(engineName: privsearchengine, url: searchURL) {
            guard let searchQuery: String = getQueryValue(engineName: privsearchengine, url: searchURL) else {
                sendData(context: context, data: ["type" : "error"])
                return
            }
            redirectData = makeSearchURL(windowName: "private", query: searchQuery)
        } else {
            sendData(context: context, data: ["type" : "cancel"])
            return
        }
        
        struct dataSet: Encodable {
            let type: String
            let redirectTo: String
            let postData: [[String: String]]
        }
        
        let sendData = dataSet(
            type: "redirect",
            redirectTo: redirectData.url,
            postData: redirectData.post
        )
        
        do {
            let data = try JSONEncoder().encode(sendData)
            let json = String(data: data, encoding: .utf8)!
            let extensionItem = NSExtensionItem()
            extensionItem.userInfo = [ SFExtensionMessageKey: json ]
            context.completeRequest(returningItems: [extensionItem], completionHandler: nil)
        } catch {
            print("error")
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
        if let checkFn = engine.check,
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
        
        // Get query
        let queryItems = urlComponents.queryItems ?? []
        let queryValue = queryItems.first(where: { $0.name == mainParam })?.value
        
        // URL Encode
        guard let queryEncoded = queryValue?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        // Return query
        return queryEncoded
    }
    
    func makeSearchURL(windowName: String, query: String) -> (url: String, post: [[String: String]]) {
        // Load Settings
        let defaultCSEData = userDefaults.dictionary(forKey: "defaultCSE") ?? [:]
        let privateCSEData = userDefaults.dictionary(forKey: "privateCSE") ?? [:]
        let quickCSEData = userDefaults.dictionary(forKey: "quickCSE") as? [String: [String: Any]] ?? [:]
        
        var CSEData: Dictionary<String, Any> = [:]
        var cseID: String = ""
        var fixedQuery: String = query

        // Check quick search
        for key in quickCSEData.keys {
            // If query has maybe quick search keyword
            if query.hasPrefix(key) && (key.count + 1 < query.count) {
                let queryNoKey = String(query.dropFirst(key.count))
                // If query has space
                if queryNoKey.hasPrefix("+") {
                    cseID = key
                    fixedQuery = String(queryNoKey.dropFirst(1))
                    break
                }
            }
        }
        
        // Get CSE Data
        if cseID == "" {
            CSEData = windowName == "private" ? privateCSEData : defaultCSEData
        } else {
            CSEData = quickCSEData[cseID] ?? [:]
        }
        
        // Replace %s with query
        let redirectURL: String = (CSEData["url"] as! String).replacingOccurrences(of: "%s", with: fixedQuery)
        var postData = CSEData["post"] as! [[String: String]]
        for i in 0..<postData.count {
            postData[i]["key"] = postData[i]["key"]?.replacingOccurrences(of: "%s", with: fixedQuery)
            postData[i]["value"] = postData[i]["value"]?.replacingOccurrences(of: "%s", with: fixedQuery)
        }
        
        return (redirectURL, postData)
    }
}

