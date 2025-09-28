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
    
    // POST Redirector
    const runPostRedirect = (response) => {
        if (isAlreadyRun) { return; } // Prevent multiple runs
        isAlreadyRun = true;
        
        // Remove query
        const urlNoQuery = window.location.origin + window.location.pathname;
        window.history.replaceState({}, '', urlNoQuery);
        
        // Read <form>
        const cseForm = document.getElementById("cseForm");
        cseForm.action = response.redirectTo;
        
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
})();
