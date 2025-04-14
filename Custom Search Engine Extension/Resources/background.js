let holdData = [];
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";

browser.tabs.onUpdated.addListener((tabId, sender, sendResponse) => {
    console.log("Tab updated: " + tabId);
    console.log("Sender: " + JSON.stringify(sender));
    console.log("SendResponse: " + JSON.stringify(sendResponse));
    
    // If this request is from content
    if (sender.url && sender.url != postRedirectorURL && sender.url != "") {
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", sender.url, function(response) {
            const cseData = JSON.parse(response);
            console.log("aaaaaaa" + cseData);
            
            // type handler
            if (cseData.type == "redirect") {
                console.log("Run redirect.");
                browser.tabs.update(tabId, {url: cseData.redirectTo});
                return;
                
            } else if (cseData.type == "haspost") {
                holdData = cseData;
                if (!cseData.adv_ignorePOSTFallback) {
                    console.log("Open POST Redirector.");
                    browser.tabs.update(tabId, {url: postRedirectorURL});
                }
                return;
                
            } else if (cseData.type == "error") {
                console.log("Aborted due to an error.");
                
            } else if (cseData.type == "cancel") {
                console.log("Operation canceled.");
                
            }
            
            sendResponse("kill");
            return;
        });
    }
    
    return true;
});

// If POST Redirect
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.type == "post_redirector" || request.type == "content") {
        console.log("Run redirect (with POST).");
        sendResponse(holdData);
        holdData = [];
    }
});
    
