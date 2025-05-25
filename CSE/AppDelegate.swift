//
//  AppDelegate.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2022/07/23.
//

import UIKit
import StoreKit

// Global constants
let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let currentRegion = Locale.current.region?.identifier
let userDefaults = CSEDataManager.userDefaults

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Get userDefaults
        let lastVersion: String = userDefaults.string(forKey: "LastAppVer") ?? ""
        let searchengine: String? = userDefaults.string(forKey: "searchengine") ?? nil
        let privsearchengine: String? = userDefaults.string(forKey: "privsearchengine") ?? nil
        let urltop: String = userDefaults.string(forKey: "urltop") ?? ""
        let urlsuffix: String = userDefaults.string(forKey: "urlsuffix") ?? ""
        let defaultCSE = CSEDataManager.getCSEData(cseType: .defaultCSE)
        let adv_resetCSEs: String = userDefaults.string(forKey: "adv_resetCSEs") ?? ""
        
        // adv_resetCSEs
        if adv_resetCSEs != "" {
            resetCSE(target: adv_resetCSEs)
            userDefaults.set("", forKey: "adv_resetCSEs")
        }
        
        // Update/Create database for v3.0 or later
        if lastVersion == "" || isUpdated(updateVer: "3.0", lastVer: lastVersion) {
            // Change default settings for macOS or under iOS 17
            #if macOS
            userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            #endif
            if #unavailable(iOS 17.0) {
                userDefaults.set(true, forKey: "adv_ignorePOSTFallback")
            }
            
            // Initialize settings
            userDefaults.set(true, forKey: "needFirstTutorial")
            userDefaults.set(true, forKey: "alsousepriv")
            if searchengine == nil {
                userDefaults.set("google", forKey: "searchengine")
            }
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            resetCSE(target: "all")
            
            // Update old CSE settings
            if (urltop != "" || urlsuffix != "") {
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
        // Cannot use Google under iOS 17
        if #unavailable(iOS 17.0, macOS 14.0) {
            if searchengine == "google" || searchengine == nil {
                if currentRegion == "CN" {
                    userDefaults.set("baidu", forKey: "searchengine")
                } else {
                    userDefaults.set("bing", forKey: "searchengine")
                }
                if isUpdated(updateVer: "3.3", lastVer: lastVersion) {
                    userDefaults.set(true, forKey: "needSafariTutorial")
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
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        
        // Fix Private SE by region
        if (currentRegion != "CN" && ["baidu", "sogou", "360search"].contains(privsearchengine))
            || (currentRegion != "RU" && ["yandex"].contains(privsearchengine)) {
            userDefaults.set("duckduckgo", forKey: "privsearchengine")
            userDefaults.set(true, forKey: "needSafariTutorial")
        }
        
        // Save last opened version
        userDefaults.set(currentVersion, forKey: "LastAppVer")
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // Reset CSEs | target == 'all' or 'default' or 'private' or 'quick'
    private func resetCSE(target: String) {
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
            "url": "",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ]
        
        let privateCSE: [String: Any] = [
            "url": "",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ]
        
        var quickCSE: [String: [String: Any]] = [
            "g": [
                "name": "Google",
                "url": "https://www.google.com/search?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "b": [
                "name": "Bing",
                "url": "https://www.bing.com/search?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "y": [
                "name": "Yahoo",
                "url": "https://search.yahoo.com/search?p=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "ddg": [
                "name": "DuckDuckGo",
                "url": "https://duckduckgo.com/?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": 500
            ],
            "eco": [
                "name": "Ecosia",
                "url": "https://www.ecosia.org/search?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "sp": [
                "name": "Startpage",
                "url": "https://www.startpage.com/sp/search?query=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "br": [
                "name": "Brave Search",
                "url": "https://search.brave.com/search?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "yt": [
                "name": "YouTube",
                "url": "https://www.youtube.com/results?search_query=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "gh": [
                "name": "GitHub",
                "url": "https://github.com/search?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "wiki": [
                "name": "Wikipedia (" + wikiLang + ")",
                "url": "https://" + wikiLang + ".wikipedia.org/w/index.php?title=Special:Search&search=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": 300
            ],
            "wbm": [
                "name": "Wayback Machine",
                "url": "https://web.archive.org/web/*/%s",
                "post": [],
                "disablePercentEncoding": true,
                "maxQueryLength": -1
            ]
        ]
        
        // ↓ country/region based Quick SE ↓
        let quickCSEJP: [String: [String: Any]] = [
            "y": [
                "name": "Yahoo! Japan",
                "url": "https://search.yahoo.co.jp/search?p=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "nico": [
                "name": "ニコニコ動画",
                "url": "https://www.nicovideo.jp/search/%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": 256
            ]
        ]
        
        let quickCSECN: [String: [String: Any]] = [
            "baidu": [
                "name": "百度",
                "url": "https://www.baidu.com/s?wd=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "weibo": [
                "name": "微博",
                "url": "https://s.weibo.com/weibo?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ],
            "bili": [
                "name": "哔哩哔哩",
                "url": "https://search.bilibili.com/all?keyword=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ]
        ]
        
        let quickCSEFR: [String: [String: Any]] = [
            "qwant": [
                "name": "Qwant",
                "url": "https://www.qwant.com/?q=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ]
        ]
        
        let quickCSEKR: [String: [String: Any]] = [
            "naver": [
                "name": "NAVER",
                "url": "https://search.naver.com/search.naver?query=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
            ]
        ]
        
        let quickCSEVN: [String: [String: Any]] = [
            "coc": [
                "name": "Cốc Cốc",
                "url": "https://coccoc.com/search#query=%s",
                "post": [],
                "disablePercentEncoding": false,
                "maxQueryLength": -1
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
        } else if currentRegion == "VN" {
            for (key, value) in quickCSEVN {
                quickCSE[key] = value
            }
        }
        
        // Save Data
        if target == "default" || target == "all" {
            userDefaults.set(defaultCSE, forKey: "defaultCSE")
        }
        if target == "private" || target == "all" {
            userDefaults.set(privateCSE, forKey: "privateCSE")
        }
        if target == "quick" || target == "all" {
            userDefaults.set(quickCSE, forKey: "quickCSE")
        }
    }
    
    // Version high and low
    private func isUpdated(updateVer: String, lastVer: String) -> Bool {
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
}
