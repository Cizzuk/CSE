let holdData = []
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    
    // If this request is from content
    if (request.type == "content") {
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", sender.url, function(response) {
            const cseData = JSON.parse(response);
            
            // type handler
            if (cseData.type == "redirect" || cseData.adv_ignorePOSTFallback) {
                console.log("Run redirect.");
                sendResponse(cseData);
                return;
                
            } else if (cseData.type == "haspost") {
                holdData = cseData;
                const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
                console.log("Open POST Redirector.");
                sendResponse({type: "redirect", redirectTo: postRedirectorURL});
                return;
                
            } else if (cseData.type == "error") {
                console.log("Aborted due to an error.");
                
            } else if (cseData.type == "cancel") {
                console.log("Operation canceled.");
                
            }
            
            sendResponse("kill");
            return;
        });
        
    // If this request is from post_redirector
    } else if (request.type == "post_redirector") {
        console.log("Run redirect (with POST).");
        sendResponse(holdData);
        holdData = []
    }
    
    return true;
});
