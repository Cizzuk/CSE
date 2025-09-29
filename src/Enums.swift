//
//  Enums.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/08/07.
//

import Foundation

enum SafariSEs: String, CaseIterable {
    
    // Helpers
    private static let currentRegion = Locale.current.region?.identifier
    
    private static func containsLanguage(_ languageCode: String) -> Bool {
        let preferredLanguages = Locale.preferredLanguages
        return preferredLanguages.contains { language in
            let locale = Locale(identifier: language)
            return locale.language.languageCode?.identifier == languageCode
        }
    }
    
    case google, bing, yahoo, duckduckgo, ecosia, baidu, sogou, yandex, so360search = "360search"
    
    var displayName: String {
        switch self {
        case .google: return "Google"
        case .bing: return "Bing"
        case .yahoo: return "Yahoo"
        case .duckduckgo: return "DuckDuckGo"
        case .ecosia: return "Ecosia"
        case .baidu: return "Baidu"
        case .sogou: return "Sogou"
        case .yandex: return "Yandex"
        case .so360search: return "360 Search"
        }
    }
    
    var domains: String {
        let region = Self.currentRegion
        switch self {
        case .google: 
            if region == "CN" {
                return "google.cn"
            } else {
                return "google.com"
            }
        case .bing: return "bing.com"
        case .yahoo:
            if region == "JP" {
                return "search.yahoo.co.jp"
            } else {
                return "search.yahoo.com"
            }
        case .duckduckgo: return "duckduckgo.com"
        case .ecosia: return "ecosia.org"
        case .baidu: return "baidu.com"
        case .sogou: return "sogou.com"
        case .yandex: return "yandex.ru"
        case .so360search: return "so.com"
        }
    }
    
    func matchesHost(_ host: String) -> Bool {
        let targetDomain = self.domains
        // Ignore subdomains
        return host == targetDomain || host.hasSuffix("." + targetDomain)
    }
    
    func path(for domain: String) -> String {
        switch self {
        case .google, .bing, .yahoo, .ecosia, .yandex: return "/search"
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
    
    func checkParameter(for domain: String) -> CheckItem? {
        switch self {
        case .google:
            return CheckItem(param: "client", values: ["safari"])
        case .yahoo:
            return CheckItem(param: "fr", values: ["iphone", "appsfch2", "osx"])
        case .bing:
            return CheckItem(param: "form", values: ["APIPH1", "APMCS1", "APIPA1"])
        case .duckduckgo:
            return CheckItem(param: "t", values: ["iphone", "osx", "ipad"])
        case .ecosia:
            return CheckItem(param: "tts", values: ["st_asaf_iphone", "st_asaf_macos", "st_asaf_ipad"])
        case .baidu:
            if domain == "m.baidu.com" {
            } else {
                return CheckItem(param: "tn", values: ["84053098_dg", "84053098_4_dg"])
            }
        case .yandex:
            return CheckItem(param: "clid", values: ["1906591", "1906725"])
        case .sogou, .so360search: return nil
        }
    }
    
    var isAvailable: Bool {
        let region = Self.currentRegion
        switch self {
        case .baidu, .sogou, .so360search:
            return region == "CN" || Self.containsLanguage("zh")
        case .yandex:
            return region == "RU" || Self.containsLanguage("ru")
        case .google:
            if #unavailable(iOS 17.0, macOS 14.0) {
                return false
            }
            return true
        case .bing, .yahoo, .duckduckgo, .ecosia:
            return true
        }
    }
    
    static var availableEngines: [SafariSEs] {
        return SafariSEs.allCases.filter { $0.isAvailable }
    }
    
    static var `default`: SafariSEs {
        if currentRegion == "CN" { return .baidu }
        if #unavailable(iOS 17.0, macOS 14.0) { return .bing }
        return .google
    }

    static var `private`: SafariSEs {
        return .duckduckgo
    }
}
