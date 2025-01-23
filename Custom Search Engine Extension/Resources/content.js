//"use strict";

browser.runtime.sendMessage({ url: window.location.href }, function(response) {
    if (response == "error") {
        console.log("CSE: error")
        return
    }
    console.log(response)
});

function doCSE() {
  if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      //if darkmode
      document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#1c1c1e"><body style="background:#1c1c1e"></body>';
  } else {
      //if lightmode
      document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#f2f2f7"><body style="background:#f2f2f7"></body>';
  }
  location.replace(cseURL);
  completedFlags["done"] = true;
  console.log("CSE: URL has been rewritten.");
}
