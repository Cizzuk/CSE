//
//  SafariSEs.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/08/07.
//

import Foundation

enum SafariSEs: String, CaseIterable {
    // Helpers
    private static var currentRegion: String? {
        // Check for override
        let overrideRegion_code = CSEDataManager.userDefaults.string(forKey: "adv_overrideRegion") ?? ""
        if !overrideRegion_code.isEmpty {
            return overrideRegion_code
        }
        
        return Locale.current.region?.identifier
    }
    
    private static func containsLanguage(_ languageCode: String) -> Bool {
        return Locale.preferredLanguages.contains { language in
            if language.hasPrefix(languageCode + "-") {
                return true
            }
            let locale = Locale(identifier: language)
            return locale.language.languageCode?.identifier == languageCode
        }
    }
    
    // MARK: - Standard
    
    case google, yahoo, bing, baidu, yandex, duckduckgo, sogou, so360search = "360search", ecosia
    
    var displayName: String.LocalizationValue {
        switch self {
        case .google: return "Google"
        case .yahoo: return "Yahoo"
        case .bing: return "Bing"
        case .duckduckgo: return "DuckDuckGo"
        case .ecosia: return "Ecosia"
        case .baidu: return "Baidu"
        case .sogou: return "Sogou"
        case .so360search: return "360 Search"
        case .yandex: return "Yandex"
        }
    }
    
    static var availableEngines: [SafariSEs] {
        return SafariSEs.allCases.filter { $0.isAvailable }
    }
    
    static var `default`: SafariSEs {
        if currentRegion == "CN" { return .baidu }
        if #unavailable(iOS 17.0, macOS 14.0) {
            if currentRegion != "US" { return .bing }
        }
        return .google
    }

    static var `private`: SafariSEs {
        return .duckduckgo
    }
    
    var isAvailable: Bool {
        switch self {
        case .google:
            if #unavailable(iOS 17.0, macOS 14.0) {
                return Self.currentRegion == "US"
            }
            return true
        case .yahoo, .bing, .duckduckgo, .ecosia:
            return true
        case .baidu, .sogou, .so360search:
            return Self.currentRegion == "CN" || Self.containsLanguage("zh-Hans")
        case .yandex:
            return Self.currentRegion == "RU" || Self.currentRegion == "KZ" || Self.currentRegion == "BY" || Self.containsLanguage("ru")
        }
    }
    
    // MARK: - URL Matching
    
    var domains: [String] {
        let region = Self.currentRegion
        switch self {
        case .google:
            if region == "CN" {
                return ["google.cn"] // www.google.cn
            } else if region == "HK" {
                return ["google.com", "google.com.hk"] // www.google.com, www.google.com.hk
            } else {
                return ["google.com"] // www.google.com
            }
        case .yahoo:
            if region == "JP" {
                return ["search.yahoo.co.jp", "search.yahoo.com"] // search.yahoo.co.jp, jp.search.yahoo.com
            } else {
                return ["search.yahoo.com"] // search.yahoo.com, *.search.yahoo.com
            }
        case .bing: return ["bing.com"] // www.bing.com
        case .duckduckgo: return ["duckduckgo.com"] // duckduckgo.com
        case .ecosia: return ["ecosia.org"] // www.ecosia.org
        case .baidu: return ["baidu.com"] // m.baidu.com, www.baidu.com
        case .sogou: return ["sogou.com"] // m.sogou.com, www.sogou.com
        case .so360search: return ["so.com"] // m.so.com, www.so.com
        case .yandex: return ["yandex.ru"] // yandex.ru
        }
    }
    
    func matchesHost(_ host: String) -> Bool {
        // Ignore subdomains
        return domains.contains { domain in
            host == domain || host.hasSuffix("." + domain)
        }
    }
    
    func path(for domain: String) -> String {
        switch self {
        case .google, .yahoo, .bing, .ecosia, .yandex: return "/search"
        case .duckduckgo: return "/"
        case .baidu, .so360search: return "/s"
        case .sogou: return domain == "m.sogou.com" ? "/web/sl" : "/web"
        }
    }
    
    func queryParam(for domain: String) -> String {
        switch self {
        case .google, .bing, .duckduckgo, .ecosia, .so360search: return "q"
        case .yahoo: return "p"
        case .baidu: return domain == "m.baidu.com" ? "word" : "wd"
        case .sogou: return domain == "m.sogou.com" ? "keyword" : "query"
        case .yandex: return "text"
        }
    }
    
    struct CheckItem {
        let param: String
        let values: [String]
    }
    
    func checkParameter(for domain: String) -> [CheckItem]? {
        // The first item is prioritized for deletion when automatic deletion is performed.
        
        switch self {
        case .google:
            // All: ie=UTF-8, oe=UTF-8, client=safari
            // Note: "client=safari" will hide "Open in the Google app" banner
            return [
                CheckItem(param: "ie", values: ["UTF-8"]),
                CheckItem(param: "oe", values: ["UTF-8"]),
                CheckItem(param: "client", values: ["safari"]),
            ]
        case .yahoo:
            // iPhone: iphone, applep1(jp)
            // iPad: ipad, applpd(jp)
            // Mac: aaplw, appsfch2(jp)
            if domain == "search.yahoo.co.jp" {
                return [CheckItem(param: "fr", values: ["iphone", "applep1", "ipad", "applpd", "aaplw", "appsfch2"])]
            } else {
                return [CheckItem(param: "fr", values: ["iphone", "ipad", "aaplw"])]
            }
        case .bing:
            // iPhone: APIPH1
            // iPad: APIPA1
            // Mac: APMCS1
            return [CheckItem(param: "form", values: ["APIPH1", "APIPA1", "APMCS1"])]
        case .duckduckgo:
            // iPhone: iphone
            // iPad: ipad
            // Mac: osx
            return [CheckItem(param: "t", values: ["iphone", "ipad", "osx"])]
        case .ecosia:
            // iPhone: st_asaf_iphone
            // iPad: st_asaf_ipad
            // Mac: st_asaf_macos
            return [CheckItem(param: "tts", values: ["st_asaf_iphone", "st_asaf_ipad", "st_asaf_macos"])]
        case .baidu:
            // iPhone: 1099b, 1000539d(cn)
            // iPad: 84053098_1_dg, 84053098_4_dg(cn)
            // Mac: 84053098_dg(cn)
            if domain == "m.baidu.com" {
                return [CheckItem(param: "from", values: ["1099b", "1000539d"])]
            } else {
                return [CheckItem(param: "tn", values: ["84053098_1_dg", "84053098_4_dg", "84053098_dg"])]
            }
        case .so360search:
            // iPhone: home
            // iPad: home
            // Mac: pclm
            return [CheckItem(param: "src", values: ["home", "pclm"])]
        case .yandex:
            // iPhone: 1906591
            // iPad: 1906723
            // Mac: 1906725
            return [CheckItem(param: "clid", values: ["1906591", "1906723", "1906725"])]
        case .sogou: return nil
        }
    }
    
    // MARK: - Support Functions
    
    func isMatchedURL(_ url: URL, disableChecker: Bool = false) -> Bool {
        return isMatchedURL(url.absoluteString, disableChecker: disableChecker)
    }
    
    func isMatchedURL(_ url: String, disableChecker: Bool = false) -> Bool {
        let engine = self
        
        // Make URLComponents and get host
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

        // Get Query Items
        guard let queryItems = urlComponents.queryItems else {
            return false
        }
        
        // Check if search query param exists
        let queryParam = engine.queryParam(for: host)
        guard queryItems.contains(where: { $0.name == queryParam }) else {
            return false
        }
        
        // Param Check
        if !disableChecker,
           let checkParam = engine.checkParameter(for: host) {
            // Check each param
            for item in checkParam {
                let param = item.param
                let values = item.values
                if !queryItems.contains(where: {
                    $0.name == param && values.contains($0.value ?? "")
                }) {
                    // All items must match
                    return false
                }
                        
            }
        }

        // All items matched (or no checks)
        return true
    }
    
    func getQuery(from url: URL) -> String? {
        return getQuery(from: url.absoluteString)
    }
    
    func getQuery(from url: String) -> String? {
        let engine = self
        
        // Make URLComponents and get host
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return nil
        }
        
        // Get search query param
        let queryParam = engine.queryParam(for: host)
        
        // Get %encoded Query Items
        guard let queryItems = urlComponents.percentEncodedQueryItems else { return nil }
        
        // Find search query
        if let item = queryItems.first(where: { $0.name == queryParam }) {
            return item.value
        }
        
        // Not found
        return nil
    }
}
