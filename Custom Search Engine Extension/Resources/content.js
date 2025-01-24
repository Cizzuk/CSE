browser.runtime.sendMessage({ type: "content" }, function(response) {
    console.log(response);
    if (response == "kill") {
        return;
    }
    
    // Screen curtain
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
        //if darkmode
        document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#1c1c1e"><body style="background:#1c1c1e"></body>';
    } else {
        //if lightmode
        document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="#f2f2f7"><body style="background:#f2f2f7"></body>';
    }
    
    // Remove query
    const urlNoQuery = window.location.origin + window.location.pathname;
    window.history.replaceState({}, '', urlNoQuery);
    
    // Run redirect
    window.location.replace(response.redirectTo);
});
