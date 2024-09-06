"use strict";

browser.runtime.sendMessage({ type: "content" },
    function(response) {
        const URLtop = response.top;
        const URLsuffix = response.suffix;
        const Engine = response.engine;

        const Domain = window.location.hostname;
        const Path = window.location.pathname;
        const URL = window.location.href;

        if (URLtop.startsWith("https://google.com")) {
            URLtop = URLtop.replace("https://google.com", "https://www.google.com");
        }
        if (URLtop.startsWith("https://bing.com")) {
            URLtop = URLtop.replace("https://bing.com", "https://www.bing.com");
        }
        if (URLtop.startsWith("https://www.duckduckgo.com")) {
            URLtop = URLtop.replace("https://www.duckduckgo.com", "https://duckduckgo.com");
        }
        if (URLtop.startsWith("https://ecosia.com")) {
            URLtop = URLtop.replace("https://ecosia.com", "https://www.ecosia.com");
        }
    
        const engines = {
            "google": {
                domain: ["www.google.com", "www.google.cn"],
                path: "/search",
                param: "q",
                check: { param: "client", ids: ["safari"] }
            },
            "yahoo": {
                domain: ["search.yahoo.com", "search.yahoo.co.jp"],
                path: "/search",
                param: "p",
                check: { param: "fr", ids: ["iphone", "appsfch2", "osx"] }
            },
            "bing": {
                domain: ["www.bing.com"],
                path: "/search",
                param: "q",
                check: { param: "form", ids: ["APIPH1", "APMCS1", "APIPA1"] }
            },
            "duckduckgo": {
                domain: ["duckduckgo.com"],
                path: "/",
                param: "q",
                check: { param: "t", ids: ["iphone", "osx", "ipad"] }
            },
            "ecosia": {
                domain: ["www.ecosia.org"],
                path: "/search",
                param: "q",
                check: { param: "tts", ids: ["st_asaf_iphone", "st_asaf_macos", "st_asaf_ipad"] }
            },
            "baidu": {
                domain: ["m.baidu.com", "www.baidu.com"],
                path: "/s",
                param: (domain) => domain === "m.baidu.com" ? "word" : "wd",
                check: (domain) => domain === "m.baidu.com" ? { param: "from", ids: ["1000539d"] } : { param: "tn", ids: ["84053098_dg", "84053098_4_dg"] }
            },
            "sogou": {
                domain: ["m.sogou.com", "www.sogou.com"],
                path: (domain) => domain === "m.sogou.com" ? "/web/sl" : "/web",
                param: (domain) => domain === "m.sogou.com" ? "keyword" : "query"
            },
            "360search": {
                domain: ["m.so.com", "www.so.com"],
                path: "/s",
                param: "q"
            },
            "yandex": {
                domain: ["yandex.ru"],
                path: "/search",
                param: "text"
            }
        };
    
        if (Engine in engines) {
            const engine = engines[Engine];
            if (engine.domain.includes(Domain)) {
                const path = typeof engine.path === 'function' ? engine.path(Domain) : engine.path;
                const param = typeof engine.param === 'function' ? engine.param(Domain) : engine.param;
                const check = typeof engine.check === 'function' ? engine.check(Domain) : engine.check;
                if (Path.startsWith(path) // Path starts with a search link
                    && getParam(URL, param) != null // Query exists
                    && (!check || check.ids.includes(getParam(URL, check.param))) // Search bar
                    && (!URL.startsWith(URLtop) || !URL.endsWith(URLsuffix)) // It's not CSE
                    ) {
                    let cseURL = URLtop + getParam(URL, param) + URLsuffix;
                    cseURL = checkerParamRemover(cseURL, check);
                    doCSE(cseURL);
                }
            }
        }
    }
);

function doCSE(url) {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
        //if darkmode
        document.getElementsByTagName("html")[0].innerHTML = '<body style="background:#1c1c1e"></body>';
    } else {
        //if lightmode
        document.getElementsByTagName("html")[0].innerHTML = '<body style="background:#f2f2f7"></body>';
    }
    location.replace(url);
    console.log("CSE: URL has been rewritten.");
}

function getParam(url, param) {
    const urlObj = new URL(url);
    const urlParams = new URLSearchParams(urlObj.search);
    return urlParams.get(param);
}

function checkerParamRemover(url, check) {
    if (check && check.ids.includes(getParam(url, check.param))) {
        let urlObj = new URL(url);
        urlObj.searchParams.delete(check.param);
        return urlObj.toString();
    } else {
        return url;
    }
}
