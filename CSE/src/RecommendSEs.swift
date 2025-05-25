//
//  RecommendSEs.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/15.
//

import Foundation

// This is a list of Recommended Search Engines for use in tutorials and search engine setup.

struct recommendCSEList {
    static let data: [CSEDataManager.CSEData] = [
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
        CSEDataManager.CSEData(
            name: "Kagi",
            url: "https://kagi.com/search?q=%s",
        ),
        CSEDataManager.CSEData(
            name: "Qwant",
            url: "https://www.qwant.com/?q=%s",
        ),
        CSEDataManager.CSEData(
            name: "NAVER",
            url: "https://search.naver.com/search.naver?query=%s",
        ),
        CSEDataManager.CSEData(
            name: "Cốc Cốc",
            url: "https://coccoc.com/search#query=%s",
        ),
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
        ),
        CSEDataManager.CSEData(
            name: "百度",
            url: "https://www.baidu.com/s?wd=%s",
        ),
        CSEDataManager.CSEData(
            name: "Yandex",
            url: "https://yandex.ru/search/?text=%s",
        )
    ]
}
