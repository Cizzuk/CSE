
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
        Domain = window.location.hostname;
        Path = window.location.pathname;
    
    
        //Google
        if (Engine == "google" && (Domain == "www.google.com" || Domain == "www.google.cn") && Path.startsWith('/search') && getParam('q') != null) {
            Query = getParam('q');
            doCSE();
            
        //Yahoo
        }else if (Engine == "yahoo" && Domain.endsWith('search.yahoo.com') && Path.startsWith('/search') && getParam('p') != null && (getParam('fr') == "iphone" || getParam('fr') == "appsfch2" || getParam('ipad') == "osx")) {
            Query = getParam('p');
            doCSE();
            
        //Bing
        }else if (Engine == "bing" && Domain == "www.bing.com" && Path.startsWith('/search') && getParam('q') != null && (getParam('form') == "APIPH1" || getParam('form') == "APMCS1" || getParam('form') == "APIPA1")) {
            Query = getParam('q');
            doCSE();
            
        //DuckDuckGo
        }else if (Engine == "duckduckgo" && Domain == "duckduckgo.com" && getParam('q') != null && (getParam('t') == "iphone" || getParam('t') == "osx") || getParam('t') == "ipad") {
            Query = getParam('q');
            doCSE();
            
        //Ecosia
        }else if (Engine == "ecosia" && Domain == "www.ecosia.org" && Path.startsWith('/search') && getParam('q') != null && (getParam('tts') == "st_asaf_iphone" || getParam('tts') == "st_asaf_macos" || getParam('tts') == "st_asaf_ipad")) {
            Query = getParam('q');
            doCSE();
            
        //Baidu (iPhone)
        }else if (Engine == "baidu" && Domain == "m.baidu.com" && Path.startsWith('/s') && getParam('word') != null && getParam('from') == "1000539d") {
            Query = getParam('word');
            doCSE();
            
        //Baidu (Mac/iPad)
        }else if (Engine == "baidu" && Domain == "www.baidu.com" && Path.startsWith('/s') && getParam('wd') != null && (getParam('tn') == "84053098_dg" || getParam('tn') == "84053098_4_dg")) {
            Query = getParam('wd');
            doCSE();
            
        //Sogou (iPhone)
        }else if (Engine == "sogou" && Domain == "m.sogou.com" && Path.startsWith('/web/sl') && getParam('keyword') != null) {
            Query = getParam('keyword');
            doCSE();
            
        //Sogou (Mac/iPad)
        }else if (Engine == "sogou" && Domain == "www.sogou.com" && Path.startsWith('/web') && getParam('query') != null) {
            Query = getParam('query');
            doCSE();
            
        //360 Search
        }else if (Engine == "360search" && (Domain == "m.so.com" || Domain == "www.so.com") && Path.startsWith('/s') && getParam('q') != null) {
            Query = getParam('q');
            doCSE();
            
        //Yandex
        }else if (Engine == "yandex" && Domain == "yandex.ru" && Path.startsWith('/search') && getParam('text') != null) {
            Query = getParam('text');
            doCSE();
        }
    }
);
    

function doCSE() {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        //if darkmode
        document.getElementsByTagName('html')[0].innerHTML = '<body style="background:#222"></body>';
    }else{
        //if lightmode
        document.getElementsByTagName('html')[0].innerHTML = '<body style="background:#cacacf"></body>';
    }
    location.replace(URLtop + Query + URLsuffix);
    console.log("CSE: URL has been rewritten.")
}

function getParam(name) {
    var url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
