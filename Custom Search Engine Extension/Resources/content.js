
var URLtop = "";
var URLsuffix = "";

browser.runtime.sendMessage({
    type: "content"
},
    function(response) {
        URLtop = response.top;
        URLsuffix = response.suffix;
    if (getParam('q') != null && (getParam('t') == "ipad" || getParam('t') == "iphone")) {
        location.href = "https://" + URLtop + getParam('q') + URLsuffix;
        document.getElementsByTagName('html')[0].innerHTML = '<body style="background-color:#000">';
        console.log("CSE: URL has been rewritten.")
    }
});
    

function getParam(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
