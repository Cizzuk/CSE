//
//  RecommendSEs.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/15.
//

import Foundation

class RecommendSEs {
    class func quickCSEs() -> [String: CSEDataManager.CSEData] {
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
        
        var baseCSEs = [
            "g": CSEDataManager.CSEData(
                name: "Google",
                url: "https://www.google.com/search?q=%s"
            ),
            "b": CSEDataManager.CSEData(
                name: "Bing",
                url: "https://www.bing.com/search?q=%s"
            ),
            "y": CSEDataManager.CSEData(
                name: "Yahoo",
                url: "https://search.yahoo.com/search?p=%s"
            ),
            "ddg": CSEDataManager.CSEData(
                name: "DuckDuckGo",
                url: "https://duckduckgo.com/?q=%s",
                maxQueryLength: 500
            ),
            "eco": CSEDataManager.CSEData(
                name: "Ecosia",
                url: "https://www.ecosia.org/search?q=%s"
            ),
            "sp": CSEDataManager.CSEData(
                name: "Startpage",
                url: "https://www.startpage.com/sp/search?query=%s"
            ),
            "br": CSEDataManager.CSEData(
                name: "Brave Search",
                url: "https://search.brave.com/search?q=%s"
            ),
            "yt": CSEDataManager.CSEData(
                name: "YouTube",
                url: "https://www.youtube.com/results?search_query=%s"
            ),
            "gh": CSEDataManager.CSEData(
                name: "GitHub",
                url: "https://github.com/search?q=%s"
            ),
            "wiki": CSEDataManager.CSEData(
                name: "Wikipedia (" + wikiLang + ")",
                url: "https://" + wikiLang + ".wikipedia.org/w/index.php?title=Special:Search&search=%s"
            ),
            "wbm": CSEDataManager.CSEData(
                name: "Wayback Machine",
                url: "https://web.archive.org/web/*/%s",
                disablePercentEncoding: true
            )
        ]
        
        if currentRegion == "JP" {
            baseCSEs["y"] = CSEDataManager.CSEData(
                name: "Yahoo! Japan",
                url: "https://search.yahoo.co.jp/search?p=%s"
            )
            baseCSEs["nico"] = CSEDataManager.CSEData(
                name: "ニコニコ動画",
                url: "https://www.nicovideo.jp/search/%s",
                maxQueryLength: 256
            )
        } else if currentRegion == "CN" {
            baseCSEs["baidu"] = CSEDataManager.CSEData(
                name: "百度",
                url: "https://www.baidu.com/s?wd=%s"
            )
            baseCSEs["weibo"] = CSEDataManager.CSEData(
                name: "微博",
                url: "https://s.weibo.com/weibo?q=%s"
            )
            baseCSEs["bili"] = CSEDataManager.CSEData(
                name: "哔哩哔哩",
                url: "https://search.bilibili.com/all?keyword=%s"
            )
        } else if currentRegion == "FR" {
            baseCSEs["qwant"] = CSEDataManager.CSEData(
                name: "Qwant",
                url: "https://www.qwant.com/?q=%s"
            )
        } else if currentRegion == "KR" {
            baseCSEs["naver"] = CSEDataManager.CSEData(
                name: "NAVER",
                url: "https://search.naver.com/search.naver?query=%s"
            )
        } else if currentRegion == "VN" {
            baseCSEs["coc"] = CSEDataManager.CSEData(
                name: "Cốc Cốc",
                url: "https://coccoc.com/search#query=%s"
            )
        } else if currentRegion == "RU" {
            baseCSEs["yandex"] = CSEDataManager.CSEData(
                name: "Яндекс",
                url: "https://yandex.ru/search/?text=%s"
            )
        }
        
        return baseCSEs
    }
    
    class func recommendPopCSEList() -> [CSEDataManager.CSEData] {
        var popCSEs: [CSEDataManager.CSEData] = [
            CSEDataManager.CSEData(
                name: "Startpage",
                url: "https://www.startpage.com/sp/search?query=%s",
            ),
            CSEDataManager.CSEData(
                name: "Brave Search",
                url: "https://search.brave.com/search?q=%s",
            ),
            CSEDataManager.CSEData(
                name: "Google &udm=14",
                url: "https://www.google.com/search?q=%s&udm=14",
            ),
        ]
        
        // Add region-specific search engines
        if currentRegion == "FR" {
            popCSEs.append(CSEDataManager.CSEData(
                name: "Qwant",
                url: "https://www.qwant.com/?q=%s"
            ))
        } else if currentRegion == "KR" {
            popCSEs.append(CSEDataManager.CSEData(
                name: "NAVER",
                url: "https://search.naver.com/search.naver?query=%s"
            ))
        } else if currentRegion == "VN" {
            popCSEs.append(CSEDataManager.CSEData(
                name: "Cốc Cốc",
                url: "https://coccoc.com/search#query=%s"
            ))
        }
        
        return popCSEs
    }
        
    class func recommendAICSEList() -> [CSEDataManager.CSEData] {
        var aiCSEs: [CSEDataManager.CSEData] = []
        if currentRegion != "CN" && currentRegion != "RU" {
            aiCSEs.append(CSEDataManager.CSEData(
                name: "Perplexity",
                url: "https://www.perplexity.ai/?q=%s"
            ))
            aiCSEs.append(CSEDataManager.CSEData(
                name: "Microsoft Copilot",
                url: "https://www.bing.com/copilotsearch?q=%s"
            ))
            aiCSEs.append(CSEDataManager.CSEData(
                name: "ChatGPT",
                url: "https://chatgpt.com/?q=%s&hints=search",
            ))
        } else if currentRegion == "CN" {
            aiCSEs.append(CSEDataManager.CSEData(
                name: "百度AI搜索",
                url: "https://chat.baidu.com/search?query=%s"
            ))
        }
        return aiCSEs
    }
    
    class func recommendNormalCSEList() -> [CSEDataManager.CSEData] {
        var normalCSEs: [CSEDataManager.CSEData] = [
            CSEDataManager.CSEData(
                name: "Google",
                url: "https://www.google.com/search?q=%s",
            ),
            CSEDataManager.CSEData(
                name: "Bing",
                url: "https://www.bing.com/search?q=%s",
            ),
            CSEDataManager.CSEData(
                name: "Yahoo",
                url: "https://search.yahoo.com/search?p=%s",
            ),
            CSEDataManager.CSEData(
                name: "DuckDuckGo",
                url: "https://duckduckgo.com/?q=%s",
                maxQueryLength: 500
            ),
            CSEDataManager.CSEData(
                name: "Ecosia",
                url: "https://www.ecosia.org/search?q=%s",
            )
        ]
        
        if currentRegion == "JP" {
            normalCSEs.append(CSEDataManager.CSEData(
                name: "Yahoo! Japan",
                url: "https://search.yahoo.co.jp/search?p=%s"
            ))
        } else if currentRegion == "CN" {
            normalCSEs.append(CSEDataManager.CSEData(
                name: "百度",
                url: "https://www.baidu.com/s?wd=%s"
            ))
        } else if currentRegion == "RU" {
            normalCSEs.append(CSEDataManager.CSEData(
                name: "Яндекс",
                url: "https://yandex.ru/search/?text=%s"
            ))
        }
        
        return normalCSEs
    }
        
}
