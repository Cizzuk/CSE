//
//  AppDelegate.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

import UIKit
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentRegion = Locale.current.regionCode
        
        // Get userDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
        let lastVersion: String = userDefaults.string(forKey: "LastAppVer") ?? ""
        let searchengine: String? = userDefaults.string(forKey: "searchengine") ?? nil
        let privsearchengine: String? = userDefaults.string(forKey: "privsearchengine") ?? nil
        let urltop: String = userDefaults.string(forKey: "urltop") ?? ""
        let urlsuffix: String = userDefaults.string(forKey: "urlsuffix") ?? ""
        let defaultCSE = userDefaults.dictionary(forKey: "defaultCSE")
        let adv_resetCSEs: String = userDefaults.string(forKey: "adv_resetCSEs") ?? ""
        
        // adv_resetCSEs
        if adv_resetCSEs != "" {
            resetCSE(target: adv_resetCSEs)
            userDefaults.set("", forKey: "adv_resetCSEs")
        }
        
        // Update/Create database for v3.0 or later
        if lastVersion == "" || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
            #if macOS
            userDefaults.set(true, forKey: "ignorePOSTFallback")
            #endif
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(true, forKey: "alsousepriv")
            if searchengine == nil {
                userDefaults.set("google", forKey: "searchengine")
            }
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            resetCSE(target: "all")
            
            // Update old CSE
            if (urltop != "" || urlsuffix != "") && defaultCSE == nil {
                let defaultCSE: [String: Any] = [
                    "name": "Default Search Engine",
                    "url": urltop + "%s" + urlsuffix,
                    "post": []
                ]
                userDefaults.set(defaultCSE, forKey: "defaultCSE")
                userDefaults.removeObject(forKey: "urltop")
                userDefaults.removeObject(forKey: "urlsuffix")
            }
        }
        
        // Automatically corrects settings to match OS version
        if #unavailable(iOS 17.0, macOS 14.0) {
            if searchengine == "google" {
                if currentRegion == "CN" {
                    userDefaults.set("baidu", forKey: "searchengine")
                } else {
                    userDefaults.set("duckduckgo", forKey: "searchengine")
                }
                if isUpdated(updateVer: "3.3", lastVer: lastVersion) {
                    userDefaults.set(true, forKey: "needFirstTutorial")
                }
            }
            userDefaults.set(true, forKey: "alsousepriv")
        }
        
        // Fix Default SE by region
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(searchengine))
           || (currentRegion != "RU" && ["yandex"].contains(searchengine)) {
            if currentRegion == "CN" {
                userDefaults.set("baidu", forKey: "searchengine")
            } else {
                userDefaults.set("google", forKey: "searchengine")
            }
        }
        
        // Fix Private SE by region
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(privsearchengine))
            || (currentRegion != "RU" && ["yandex"].contains(privsearchengine)) {
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
        }

        // Save last opened version
        userDefaults.set(currentVersion, forKey: "LastAppVer")
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

// Reset CSEs | target == 'all' or 'default' or 'private' or 'quick'
func resetCSE(target: String) {
    let currentRegion = Locale.current.regionCode
    
    // Wikipedia
    let preferredLanguages = Locale.preferredLanguages
    let wikiLangsList: [String] = ["ar", "de", "en", "es", "fa", "fr", "it", "arz", "nl", "ja", "pl", "pt", "ceb", "sv", "uk", "vi", "war", "zh", "ru"]
    var wikiLang: String = "en"
    for language in preferredLanguages {
        let languageCode = language.components(separatedBy: "-").first ?? language
        if wikiLangsList.contains(languageCode) {
            wikiLang = languageCode
            break
        }
    }
    
    let defaultCSE: [String: Any] = [
        "url": "https://www.google.com/search?q=%s",
        "post": []
    ]
    
    // Only for China mainland
    let defaultCSECN: [String: Any] = [
        "url": "https://www.baidu.com/s?wd=%s",
        "post": []
    ]

    let privateCSE: [String: Any] = [
        "url": "https://duckduckgo.com/?q=%s",
        "post": []
    ]

    var quickCSE: [String: [String: Any]] = [
        "g": [
            "name": "Google",
            "url": "https://www.google.com/search?q=%s",
            "post": []
        ],
        "b": [
            "name": "Bing",
            "url": "https://www.bing.com/search?q=%s",
            "post": []
        ],
        "y": [
            "name": "Yahoo",
            "url": "https://search.yahoo.com/search?p=%s",
            "post": []
        ],
        "ddg": [
            "name": "DuckDuckGo",
            "url": "https://duckduckgo.com/?q=%s",
            "post": []
        ],
        "eco": [
            "name": "Ecosia",
            "url": "https://www.ecosia.org/search?q=%s",
            "post": []
        ],
        "sp": [
            "name": "Startpage",
            "url": "https://www.startpage.com/sp/search",
            "post": [
                ["key": "query", "value": "%s"]
            ]
        ],
        "br": [
            "name": "Brave Search",
            "url": "https://search.brave.com/search?q=%s",
            "post": []
        ],
        "yt": [
            "name": "YouTube",
            "url": "https://www.youtube.com/results?search_query=%s",
            "post": []
        ],
        "gh": [
            "name": "GitHub",
            "url": "https://github.com/search?q=%s",
            "post": []
        ],
        "wiki": [
            "name": "Wikipedia (" + wikiLang + ")",
            "url": "https://" + wikiLang + ".wikipedia.org/w/index.php?title=Special:Search&search=%s",
            "post": []
        ],
        "wbm": [
            "name": "Wayback Machine",
            "url": "https://web.archive.org/web/*/%s",
            "post": []
        ]
    ]
    
    // ↓ country/region based Quick SE ↓
    let quickCSEJP: [String: [String: Any]] = [
        "y": [
            "name": "Yahoo! Japan",
            "url": "https://search.yahoo.co.jp/search?p=%s",
            "post": []
        ],
        "nico": [
            "name": "ニコニコ動画",
            "url": "https://www.nicovideo.jp/search/%s",
            "post": []
        ]
    ]
    
    let quickCSECN: [String: [String: Any]] = [
        "baidu": [
            "name": "百度",
            "url": "https://www.baidu.com/s?wd=%s",
            "post": []
        ],
        "weibo": [
            "name": "微博",
            "url": "https://s.weibo.com/weibo?q=%s",
            "post": []
        ],
        "bili": [
            "name": "哔哩哔哩",
            "url": "https://search.bilibili.com/all?keyword=%s",
            "post": []
        ]
    ]
    
    let quickCSEFR: [String: [String: Any]] = [
        "qwant": [
            "name": "Qwant",
            "url": "https://www.qwant.com/?q=%s",
            "post": []
        ]
    ]
            
    let quickCSEKR: [String: [String: Any]] = [
        "naver": [
            "name": "NAVER",
            "url": "https://search.naver.com/search.naver?query=%s",
            "post": []
        ]
    ]
    
    // Edit QuickSE by country/region
    if currentRegion == "JP" {
        for (key, value) in quickCSEJP {
            quickCSE[key] = value
        }
    } else if currentRegion == "CN" {
        for (key, value) in quickCSECN {
            quickCSE[key] = value
        }
    } else if currentRegion == "FR" {
        for (key, value) in quickCSEFR {
            quickCSE[key] = value
        }
    } else if currentRegion == "KR" {
        for (key, value) in quickCSEKR {
            quickCSE[key] = value
        }
    }
    
    let userDefaults = UserDefaults(suiteName: "group.com.tsg0o0.cse")!
    
    // Save Data
    if target == "default" || target == "all" {
        if currentRegion == "CN" {
            userDefaults.set(defaultCSECN, forKey: "defaultCSE")
        } else {
            userDefaults.set(defaultCSE, forKey: "defaultCSE")
        }
    }
    if target == "private" || target == "all" {
        userDefaults.set(privateCSE, forKey: "privateCSE")
    }
    if target == "quick" || target == "all" {
        userDefaults.set(quickCSE, forKey: "quickCSE")
    }
}

// Version high and low
func isUpdated(updateVer: String, lastVer: String) -> Bool {
    guard lastVer != "" else {
        return false
    }
    
    let updateComponents = updateVer.split(separator: ".").compactMap { Int($0) }
    let lastComponents = lastVer.split(separator: ".").compactMap { Int($0) }
    
    for (update, last) in zip(updateComponents, lastComponents) {
        if update > last {
            return true
        } else if update < last {
            return false
        }
    }
    
    return updateComponents.count > lastComponents.count
}
