//
//  SearchEnginePresets.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/15.
//

import Foundation

class SearchEnginePresets {
    // Helpers
    private static let currentRegion = Locale.current.region?.identifier
    private static let preferredLanguages = Locale.preferredLanguages
    
    private static func containsLanguage(_ languageCode: String) -> Bool {
        return preferredLanguages.contains { language in
            if language.hasPrefix(languageCode + "-") {
                return true
            }
            let locale = Locale(identifier: language)
            return locale.language.languageCode?.identifier == languageCode
        }
    }
    
    class func quickCSEs() -> [String: CSEDataManager.CSEData] {
        let wikiLangsList: [String] = [
            // https://ja.wikipedia.org/wiki/Wikipedia:全言語版の統計#各言語版ウィキペディア
            // Over 1M articles
            "ar", "de", "en", "es", "fa", "fr", "it", "arz", "nl", "ja", "pl", "pt", "ceb", "sv", "uk", "vi", "war", "zh", "ru",
            // Over 500K articles
            "ca", "id", "ko", "sr", "no", "tr", "fi", "ce", "cs", "hu", "ro", "tt",
        ]
        var wikiLang: String = "en"
        for language in preferredLanguages {
            let languageCode = language.components(separatedBy: "-").first ?? language
            if wikiLangsList.contains(languageCode) {
                wikiLang = languageCode
                break
            }
        }
        
        var baseCSEs = [
            "g": CSEDataManager.CSEData(
                name: "Google",
                url: "https://www.google.com/search?q=%s&client=safari",
            ),
            "b": CSEDataManager.CSEData(
                name: "Bing",
                url: "https://www.bing.com/search?q=%s",
            ),
            "y": CSEDataManager.CSEData(
                name: "Yahoo",
                url: "https://search.yahoo.com/search?p=%s",
            ),
            "ddg": CSEDataManager.CSEData(
                name: "DuckDuckGo",
                url: "https://duckduckgo.com/?q=%s",
                maxQueryLength: 500,
            ),
            "eco": CSEDataManager.CSEData(
                name: "Ecosia",
                url: "https://www.ecosia.org/search?q=%s",
            ),
            "sp": CSEDataManager.CSEData(
                name: "Startpage",
                url: "https://www.startpage.com/sp/search?query=%s",
            ),
            "br": CSEDataManager.CSEData(
                name: "Brave Search",
                url: "https://search.brave.com/search?q=%s",
            ),
            "yt": CSEDataManager.CSEData(
                name: "YouTube",
                url: "https://www.youtube.com/results?search_query=%s",
            ),
            "gh": CSEDataManager.CSEData(
                name: "GitHub",
                url: "https://github.com/search?q=%s",
            ),
            "wiki": CSEDataManager.CSEData(
                name: "Wikipedia (" + wikiLang + ")",
                url: "https://" + wikiLang + ".wikipedia.org/w/index.php?title=Special:Search&search=%s",
            ),
            "wbm": CSEDataManager.CSEData(
                name: "Wayback Machine",
                url: "https://web.archive.org/web/*/%s",
                disablePercentEncoding: true,
            ),
        ]
        
        if currentRegion != "CN" {
            baseCSEs["gpt"] = CSEDataManager.CSEData(
                name: "ChatGPT",
                url: "https://chatgpt.com/?q=%s&hints=search",
            )
            baseCSEs["pplx"] = CSEDataManager.CSEData(
                name: "Perplexity",
                url: "https://www.perplexity.ai/?q=%s",
            )
        }
        
        if preferredLanguages.first == "ja-JP" {
            baseCSEs["y"] = CSEDataManager.CSEData(
                name: "Yahoo! JAPAN",
                url: "https://search.yahoo.co.jp/search?p=%s",
            )
        }
        
        if currentRegion == "JP" || containsLanguage("ja") {
            baseCSEs["nico"] = CSEDataManager.CSEData(
                name: "ニコニコ動画",
                url: "https://www.nicovideo.jp/search/%s",
                maxQueryLength: 256,
            )
        }
        
        if currentRegion == "CN" || containsLanguage("zh-Hans") {
            baseCSEs["baidu"] = CSEDataManager.CSEData(
                name: "百度",
                url: "https://www.baidu.com/s?wd=%s",
            )
            baseCSEs["weibo"] = CSEDataManager.CSEData(
                name: "微博",
                url: "https://s.weibo.com/weibo?q=%s",
            )
            baseCSEs["bili"] = CSEDataManager.CSEData(
                name: "哔哩哔哩",
                url: "https://search.bilibili.com/all?keyword=%s",
            )
        }
        
        if currentRegion == "FR" {
            baseCSEs["qwant"] = CSEDataManager.CSEData(
                name: "Qwant",
                url: "https://www.qwant.com/?q=%s",
            )
        }
        
        if currentRegion == "KR" || containsLanguage("ko") {
            baseCSEs["naver"] = CSEDataManager.CSEData(
                name: "NAVER",
                url: "https://search.naver.com/search.naver?query=%s",
            )
        }
        
        if currentRegion == "VN" || containsLanguage("vi") {
            baseCSEs["coc"] = CSEDataManager.CSEData(
                name: "Cốc Cốc",
                url: "https://coccoc.com/search#query=%s",
            )
        }
        
        if currentRegion == "RU" || containsLanguage("ru") {
            baseCSEs["yandex"] = CSEDataManager.CSEData(
                name: "Яндекс",
                url: "https://yandex.ru/search/?text=%s",
            )
        }
        
        return baseCSEs
    }
    
    class func recommendPopCSEList() -> [CSEDataManager.CSEData] {
        var popCSEs: [CSEDataManager.CSEData] = [
            CSEDataManager.CSEData(
                name: "Startpage",
                keyword: "sp",
                url: "https://www.startpage.com/sp/search?query=%s",
            ),
            CSEDataManager.CSEData(
                name: "Brave Search",
                keyword: "br",
                url: "https://search.brave.com/search?q=%s",
            ),
            CSEDataManager.CSEData(
                name: "Google &udm=14",
                keyword: "g",
                url: "https://www.google.com/search?q=%s&udm=14&client=safari",
            ),
            CSEDataManager.CSEData(
                name: "Kagi",
                keyword: "kagi",
                url: "https://kagi.com/search?q=%s",
            ),
        ]
        
        // Add region-specific search engines
        if currentRegion == "FR" {
            popCSEs.append(CSEDataManager.CSEData(
                name: "Qwant",
                keyword: "qwant",
                url: "https://www.qwant.com/?q=%s",
            ))
        }
        
        if currentRegion == "KR" || containsLanguage("ko") {
            popCSEs.append(CSEDataManager.CSEData(
                name: "NAVER",
                keyword: "naver",
                url: "https://search.naver.com/search.naver?query=%s",
            ))
        }
        
        if currentRegion == "VN" || containsLanguage("vi") {
            popCSEs.append(CSEDataManager.CSEData(
                name: "Cốc Cốc",
                keyword: "coc",
                url: "https://coccoc.com/search#query=%s",
            ))
        }
        
        return popCSEs
    }
        
    class func recommendAICSEList() -> [CSEDataManager.CSEData] {
        var aiCSEs: [CSEDataManager.CSEData] = []
        if currentRegion != "CN" {
            aiCSEs.append(contentsOf: [
                // Search Engine (Mode)
                CSEDataManager.CSEData(
                    name: "ChatGPT",
                    keyword: "gpt",
                    url: "https://chatgpt.com/?q=%s&hints=search",
                ),
                CSEDataManager.CSEData(
                    name: "Perplexity",
                    keyword: "pplx",
                    url: "https://www.perplexity.ai/?q=%s",
                ),
                CSEDataManager.CSEData(
                    name: "Google AI Mode",
                    keyword: "gai",
                    url: "https://google.com/?q=%s&udm=50",
                ),
                CSEDataManager.CSEData(
                    name: "Microsoft Copilot",
                    keyword: "copilot",
                    url: "https://www.bing.com/copilotsearch?q=%s",
                ),
            ])
            
            if currentRegion == "JP" || containsLanguage("ja") {
                aiCSEs.append(CSEDataManager.CSEData(
                    name: "Yahoo!検索 AIアシスタント",
                    keyword: "yai",
                    url: "https://search.yahoo.co.jp/chat?q=%s",
                ))
            }
            
            // Normal AI Chat
            aiCSEs.append(contentsOf: [
                CSEDataManager.CSEData(
                    name: "Claude",
                    keyword: "claude",
                    url: "https://claude.ai/new?q=%s",
                ),
                CSEDataManager.CSEData(
                    name: "Grok",
                    keyword: "grok",
                    url: "https://grok.com/?q=%s",
                ),
            ])
        }
        
        if currentRegion == "CN" || containsLanguage("zh-Hans") {
            aiCSEs.append(CSEDataManager.CSEData(
                name: "百度AI搜索",
                keyword: "baiduai",
                url: "https://chat.baidu.com/search?query=%s",
            ))
        }
        return aiCSEs
    }
    
    class func recommendNormalCSEList() -> [CSEDataManager.CSEData] {
        var normalCSEs: [CSEDataManager.CSEData] = []
        
        let localizedYahoo: CSEDataManager.CSEData
        if preferredLanguages.first == "ja-JP" {
            localizedYahoo = CSEDataManager.CSEData(
                name: "Yahoo! JAPAN",
                keyword: "y",
                url: "https://search.yahoo.co.jp/search?p=%s",
            )
        } else {
            localizedYahoo = CSEDataManager.CSEData(
                name: "Yahoo",
                keyword: "y",
                url: "https://search.yahoo.com/search?p=%s",
            )
        }
        
        normalCSEs.append(contentsOf:[
            CSEDataManager.CSEData(
                name: "Google",
                keyword: "g",
                url: "https://www.google.com/search?q=%s&client=safari",
            ),
            CSEDataManager.CSEData(
                name: "Bing",
                keyword: "b",
                url: "https://www.bing.com/search?q=%s",
            ),
            localizedYahoo,
            CSEDataManager.CSEData(
                name: "DuckDuckGo",
                keyword: "ddg",
                url: "https://duckduckgo.com/?q=%s",
                maxQueryLength: 500,
            ),
            CSEDataManager.CSEData(
                name: "Ecosia",
                keyword: "eco",
                url: "https://www.ecosia.org/search?q=%s",
            ),
        ])
        
        if currentRegion == "CN" || containsLanguage("zh-Hans") {
            normalCSEs.append(CSEDataManager.CSEData(
                name: "百度",
                keyword: "baidu",
                url: "https://www.baidu.com/s?wd=%s",
            ))
        }
        
        if currentRegion == "RU" || containsLanguage("ru") {
            normalCSEs.append(CSEDataManager.CSEData(
                name: "Яндекс",
                keyword: "yandex",
                url: "https://yandex.ru/search/?text=%s",
            ))
        }
        
        return normalCSEs
    }
        
}
