
var URLtop = "";
var URLsuffix = "";
var Engine = "";
var Domain = "";
var Query = "";

browser.runtime.sendMessage({ type: "content" },
    function(response) {
        URLtop = response.top;
        URLsuffix = response.suffix;
        Engine = response.engine;

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
                param: "q"
            },
            "yahoo": {
                domain: ["search.yahoo.com", "search.yahoo.co.jp"],
                path: "/search",
                param: "p",
                check: () => ["iphone", "appsfch2", "osx"].includes(getParam("fr"))
            },
            "bing": {
                domain: ["www.bing.com"],
                path: "/search",
                param: "q",
                check: () => ["APIPH1", "APMCS1", "APIPA1"].includes(getParam("form"))
            },
            "duckduckgo": {
                domain: ["duckduckgo.com"],
                path: "/",
                param: "q",
                check: () => ["iphone", "osx", "ipad"].includes(getParam("t"))
            },
            "ecosia": {
                domain: ["www.ecosia.org"],
                path: "/search",
                param: "q",
                check: () => ["st_asaf_iphone", "st_asaf_macos", "st_asaf_ipad"].includes(getParam("tts"))
            },
            "baidu": {
                domain: ["m.baidu.com", "www.baidu.com"],
                path: "/s",
                param: (domain) => domain === "m.baidu.com" ? "word" : "wd",
                check: (domain) => domain === "m.baidu.com" ? getParam("from") === "1000539d" : ["84053098_dg", "84053098_4_dg"].includes(getParam("tn"))
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
            const domains = Array.isArray(engine.domain) ? engine.domain : [engine.domain];
            const paths = Array.isArray(engine.path) ? engine.path : [engine.path];
            const param = typeof engine.param === "function" ? engine.param(Domain) : engine.param;
            if (domains.includes(Domain)
                && paths.some(p => Path.startsWith(p))
                && getParam(param) != null
                && (!engine.check || engine.check(Domain))
                && (!URL.startsWith(URLtop) || !URL.endsWith(URLsuffix))
                ) {
                const Query = getParam(param);
                doCSE(URLtop, Query, URLsuffix);
            }
        }
    }
);

function doCSE(URLtop, Query, URLsuffix) {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
        //if darkmode
        document.getElementsByTagName("html")[0].innerHTML = '<body style="background:#222"></body>';
    } else {
        //if lightmode
        document.getElementsByTagName("html")[0].innerHTML = '<body style="background:#cacacf"></body>';
    }
    location.replace(URLtop + Query + URLsuffix);
    console.log("CSE: URL has been rewritten.");
}

function getParam(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
}
