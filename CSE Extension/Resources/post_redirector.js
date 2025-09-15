(function() {
    'use strict';
    // Send request to background.js
    browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
        // if no need to postRedirect
        if (response.type != "postRedirect") { return; }
        
        // Remove query
        const urlNoQuery = window.location.origin + window.location.pathname;
        window.history.replaceState({}, '', urlNoQuery);
        
        // if ignorePostFallback
        if (response.adv_ignorePOSTFallback) {
            // Screen curtain
            const darkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
            const textColor = darkMode ? "#fff" : "#000"
            const bgColor = darkMode ? "#1c1c1e" : "#f2f2f7"
            document.getElementsByTagName("html")[0].innerHTML = `
                <meta name="theme-color" content="`+bgColor+`">
                <body style="background:`+bgColor+`;color:`+textColor+`">
            `;
            
            // CSP restriction alert
            setTimeout(function() {
                alert("CSE: Redirect may have failed. Please try changing Safari search engine.");
            }, 5000);
        }
        
        // Create <form>
        const cseForm = document.createElement("form");
        cseForm.method = "post";
        cseForm.action = response.redirectTo;
        document.body.appendChild(cseForm);
        
        // Add POST Data
        response.postData.forEach(item => {
            const inputElement = document.createElement("input");
            inputElement.type = "hidden";
            inputElement.name = item.key;
            inputElement.value = item.value;
            cseForm.appendChild(inputElement);
        })
        
        // Submit form
        cseForm.submit();
    });
})();
