browser.runtime.sendMessage({ url: window.location.href }, function(response) {
    // Output log
    if (response.type == "error") {
        console.log("CSE: Aborted due to an error.")
        return
    } else if (response.type == "cancel") {
        return
    }
    console.log(response)
    
    // Screen curtain
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
        //if darkmode
        document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#1c1c1e"><body style="background:#1c1c1e"></body>';
    } else {
        //if lightmode
        document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#f2f2f7"><body style="background:#f2f2f7"></body>';
    }
    
    location.replace(cseURL);
    
    console.log("CSE: URL has been rewritten.");
});
