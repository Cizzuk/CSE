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
    
    if (response.postData.length === 0) {
        location.replace(response.redirectTo);
    } else {
        // Remove query
        const urlNoQuery = window.location.origin + window.location.pathname;
        window.history.replaceState({}, '', urlNoQuery);
        
        // Create <form>
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = response.redirectTo;
        
        // Add POST Data
        response.postData.forEach(item => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = item.key;
            input.value = item.value;
            form.appendChild(input);
        })
        
        // Submit form
        document.body.appendChild(form);
        form.submit();
    }
    
    console.log("CSE: Searched!");
});
