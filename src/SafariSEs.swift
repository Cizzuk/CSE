//
//  SafariSEs.swift
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
    
    var domains: [String] {
        let region = Self.currentRegion
        switch self {
        case .google: 
            if region == "CN" {
                return ["google.cn"] // www.google.cn
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
    
    func checkParameter(for domain: String) -> CheckItem? {
        switch self {
        case .google:
            // All: safari
            return CheckItem(param: "client", values: ["safari"])
        case .yahoo:
            // iPhone: iphone, applep1(jp)
            // iPad: ipad, applpd(jp)
            // Mac: aaplw, appsfch2(jp)
            if domain == "search.yahoo.co.jp" {
                return CheckItem(param: "fr", values: ["iphone", "applep1", "ipad", "applpd", "aaplw", "appsfch2"])
            } else {
                return CheckItem(param: "fr", values: ["iphone", "ipad", "aaplw"])
            }
        case .bing:
            // iPhone: APIPH1
            // iPad: APIPA1
            // Mac: APMCS1
            return CheckItem(param: "form", values: ["APIPH1", "APIPA1", "APMCS1"])
        case .duckduckgo:
            // iPhone: iphone
            // iPad: ipad
            // Mac: osx
            return CheckItem(param: "t", values: ["iphone", "ipad", "osx"])
        case .ecosia:
            // iPhone: st_asaf_iphone
            // iPad: st_asaf_ipad
            // Mac: st_asaf_macos
            return CheckItem(param: "tts", values: ["st_asaf_iphone", "st_asaf_ipad", "st_asaf_macos"])
        case .baidu:
            // iPhone: 1099b, 1000539d(cn)
            // iPad: 84053098_1_dg, 84053098_4_dg(cn)
            // Mac: 84053098_dg(cn)
            if domain == "m.baidu.com" {
                return CheckItem(param: "from", values: ["1099b", "1000539d"])
            } else {
                return CheckItem(param: "tn", values: ["84053098_1_dg", "84053098_4_dg", "84053098_dg"])
            }
        case .so360search:
            // iPhone: home
            // iPad: home
            // Mac: pclm
            return CheckItem(param: "src", values: ["home", "pclm"])
        case .yandex:
            // iPhone: 1906591
            // iPad: 1906723
            // Mac: 1906725
            return CheckItem(param: "clid", values: ["1906591", "1906723", "1906725"])
        case .sogou: return nil
        }
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
            return Self.currentRegion == "CN" || Self.containsLanguage("zh")
        case .yandex:
            return Self.currentRegion == "RU" || Self.currentRegion == "KZ" || Self.currentRegion == "BY" || Self.containsLanguage("ru")
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
}
