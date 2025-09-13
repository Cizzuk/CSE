//
//  Enums.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/08/07.
//

import Foundation

enum SafariSEs: String, CaseIterable {
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
    
    func domain(forRegion region: String?) -> String {
        switch self {
        case .google: return region == "CN" ? "google.cn" : "google.com"
        case .bing: return "bing.com"
        case .yahoo: return region == "JP" ? "search.yahoo.co.jp" : "search.yahoo.com"
        case .duckduckgo: return "duckduckgo.com"
        case .ecosia: return "ecosia.org"
        case .baidu: return "baidu.com"
        case .sogou: return "sogou.com"
        case .yandex: return "yandex.ru"
        case .so360search: return "so.com"
        }
    }
    
    func isAvailable(forRegion region: String?) -> Bool {
        switch self {
        case .baidu, .sogou, .so360search:
            return region == "CN"
        case .yandex:
            return region == "RU"
        case .google:
            if #unavailable(iOS 17.0, macOS 14.0) {
                return false
            }
            return true
        case .bing, .yahoo, .duckduckgo, .ecosia:
            return true
        }
    }
    
    static func availableEngines(forRegion region: String?) -> [SafariSEs] {
        return SafariSEs.allCases.filter { $0.isAvailable(forRegion: region) }
    }
    
    static func defaultForRegion(region: String?) -> SafariSEs {
        if region == "CN" { return .baidu }
        if #unavailable(iOS 17.0, macOS 14.0) { return .bing }
        return .google
    }

    static func privateForRegion(region: String?) -> SafariSEs {
        return .duckduckgo
    }
}
