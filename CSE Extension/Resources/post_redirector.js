(function() {
    'use strict';
    browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
        // if no need to postRedirect
        if (response.type != "postRedirect") { return; }
        
        // if ignorePostFallback
        if (response.adv_ignorePOSTFallback) {
            // Remove query
            const urlNoQuery = window.location.origin + window.location.pathname;
            window.history.replaceState({}, '', urlNoQuery);
            
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
