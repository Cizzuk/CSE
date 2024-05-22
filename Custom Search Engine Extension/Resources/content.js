
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
    
        //DuckDuckGo
        if (Engine == "duckduckgo" && Domain == "duckduckgo.com" && getParam('q') != null && (getParam('t') == "ipad" || getParam('t') == "iphone" || getParam('t') == "osx")) {
            Query = getParam('q');
            doCSE();
            
        //Sogou (Mobile)
        }else if (Engine == "sogou" && Domain == "m.sogou.com" && getParam('keyword') != null && window.location.pathname.startsWith('/web/sl')) {
            Query = getParam('keyword');
            doCSE();
            
        //Sogou (PC)
        }else if (Engine == "sogou" && Domain == "www.sogou.com" && getParam('query') != null && getParam('_asf') != "www.sogou.com") {
            Query = getParam('query');
            doCSE();
            
        //Yandex
        }else if (Engine == "yandex" && Domain == "yandex.ru" && getParam('text') != null) {
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
