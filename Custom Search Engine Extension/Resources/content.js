
var URLtop = "";
var URLsuffix = "";
var Engine = "";

browser.runtime.sendMessage({
    type: "content"
},
    function(response) {
        URLtop = response.top;
        URLsuffix = response.suffix;
        Engine = response.engine;
    if (Engine == "duckduckgo") {
        if (getParam('q') != null && (getParam('t') == "ipad" || getParam('t') == "iphone" || getParam('t') == "osx")) {
            location.href = URLtop + getParam('q') + URLsuffix;
            CSELog();
        }
    }else if (Engine == "baidu") {
        if (getParam('word') != null) {
            location.href = URLtop + getParam('word') + URLsuffix;
            CSELog();
        }
    }else if (Engine == "yandex") {
        if (getParam('text') != null) {
            location.href = URLtop + getParam('text') + URLsuffix;
            CSELog();
        }
    }
});
    

function CSELog() {
    document.getElementsByTagName('html')[0].innerHTML = '<body style="background:#000;Color:#ccc;font-family:sans-serif;text-align:center"><h1>Customize Search Engine</h1><p><strong>Redirecting...</strong></p></body>';
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
