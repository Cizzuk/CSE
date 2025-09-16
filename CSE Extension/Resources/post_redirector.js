(function() {
    'use strict';
    let isAlreadyRun = false;
    
    // Send message to background.js
    document.addEventListener("readystatechange", (event) => {
        if (event.target.readyState === "interactive") {
            browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
                // if no need to postRedirect
                if (response.type !== "postRedirect") { return; }
                runPostRedirect(response);
            });
        }
    });
    
    // Recieve message from background.js
    browser.runtime.onMessage.addListener((message) => {
        if (message.type === "postRedirect") {
            runPostRedirect(message);
            return Promise.resolve("done");
        }
        if (message.type === "showCurtain") { showCurtain(); }
    });
    
    // POST Redirector
    const runPostRedirect = (response) => {
        if (isAlreadyRun) { return; } // Prevent multiple runs
        isAlreadyRun = true;
        
        // Remove query
        const urlNoQuery = window.location.origin + window.location.pathname;
        window.history.replaceState({}, '', urlNoQuery);
        
        // Show screen curtain
        showCurtain();
        
        // if ignorePostFallback
        if (response.adv_ignorePOSTFallback) {
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
    }
    
    // Screen curtain
    const showCurtain = () => {
        const htmlDOM = document.getElementsByTagName("html")[0];
        const darkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;
        const bgColor = darkMode ? "#1c1c1e" : "#f2f2f7"
        htmlDOM.style.background = bgColor;
        htmlDOM.innerHTML = `
            <meta name="theme-color" content="`+bgColor+`">
            <body style="display:none">
        `;
    }
})();
