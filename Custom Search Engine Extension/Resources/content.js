browser.runtime.sendMessage({ type: "content" }, function(response) {
    if (response == "kill") {
        return;
    } else if (!response.redirectTo) {
        return;
    }
    
    // Screen curtain
    const textColor = window.matchMedia("(prefers-color-scheme: dark)").matches ? "#fff" : "#000"
    const bgColor = window.matchMedia("(prefers-color-scheme: dark)").matches ? "#1c1c1e" : "#f2f2f7"
    document.getElementsByTagName("html")[0].innerHTML = '<meta name="theme-color" content="' + bgColor + '"><body style="background:' + bgColor + ';color:' + textColor + ';font-family:system-ui"></body>';
    
    // Remove query
    const urlNoQuery = window.location.origin + window.location.pathname;
    window.history.replaceState({}, '', urlNoQuery);
    
    if (response.adv_ignorePOSTFallback && response.type == "haspost") {
        // Create <form>
        var formDOM = '<form id="cseForm" method="post" action="' + response.redirectTo + '">';
        
        // Add POST Data
        response.postData.forEach(item => {
            formDOM += '<input type="hidden" name="' + item.key + '" value="' + item.value + '"></input>';
        })
        
        formDOM += '</form>';
        
        // Submit form
        document.getElementsByTagName("body")[0].innerHTML = formDOM;
        cseForm.submit();
        setTimeout(function() {
            document.getElementsByTagName("body")[0].innerHTML += '<p><b>CSE: </b>If the redirect does not work, try changing Safari default search engine.</p>';
        }, 5000);
    } else {
        // Run redirect
        window.location.replace(response.redirectTo);
    }
});
