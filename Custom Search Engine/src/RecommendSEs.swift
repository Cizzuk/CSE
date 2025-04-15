//
//  RecommendSEs.swift
//  Customize Search Engine
//
//  Created by Cizzuk on 2025/04/15.
//

import Foundation

struct recommendCSEList {
    static let data: [[String: Any]] = [
        [
            "name": "Startpage",
            "url": "https://www.startpage.com/sp/search?query=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Brave Search",
            "url": "https://search.brave.com/search?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Google &udm=14",
            "url": "https://www.google.com/search?q=%s&udm=14",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Kagi",
            "url": "https://kagi.com/search?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Qwant",
            "url": "https://www.qwant.com/?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "NAVER",
            "url": "https://search.naver.com/search.naver?query=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Cốc Cốc",
            "url": "https://coccoc.com/search#query=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Google",
            "url": "https://www.google.com/search?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Bing",
            "url": "https://www.bing.com/search?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Yahoo",
            "url": "https://search.yahoo.com/search?p=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "DuckDuckGo",
            "url": "https://duckduckgo.com/?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": 500
        ],
        [
            "name": "Ecosia",
            "url": "https://www.ecosia.org/search?q=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "百度",
            "url": "https://www.baidu.com/s?wd=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ],
        [
            "name": "Yandex",
            "url": "https://yandex.ru/search/?text=%s",
            "post": [],
            "disablePercentEncoding": false,
            "maxQueryLength": -1
        ]
    ]
}
