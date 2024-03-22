
var URLtop = "";
var URLsuffix = "";
var Engine = "";
var Domain = "";

browser.runtime.sendMessage({
    type: "content"
},
    function(response) {
        URLtop = response.top;
        URLsuffix = response.suffix;
        Engine = response.engine;
        Domain = window.location.hostname;
        if (Engine == "duckduckgo" && Domain == "duckduckgo.com") {
            if (getParam('q') != null && (getParam('t') == "ipad" || getParam('t') == "iphone" || getParam('t') == "osx")) {
                location.href = URLtop + getParam('q') + URLsuffix;
                CSELog();
            }
        }else if (Engine == "sogou" && Domain == "m.sogou.com") {
            if (getParam('keyword') != null) {
                location.href = URLtop + getParam('word') + URLsuffix;
                CSELog();
            }
        }else if (Engine == "sogou" && Domain == "www.sogou.com") {
            if (getParam('query') != null) {
                location.href = URLtop + getParam('word') + URLsuffix;
                CSELog();
            }
        }else if (Engine == "yandex" && Domain == "yandex.ru") {
            if (getParam('text') != null) {
                location.href = URLtop + getParam('text') + URLsuffix;
                CSELog();
            }
        }
    });
    

function CSELog() {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        //if darkmode
        document.getElementsByTagName('html')[0].innerHTML = '<body style="background:#222"></body>';
    }else{
        //if lightmode
        document.getElementsByTagName('html')[0].innerHTML = '<body style="background:#cacacf"></body>';
    }
    console.log("CSE: URL has been rewritten.")
}

function getParam(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
