'use strict';
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let savedData = {};
let savedTabURL = {};

// Detect tab updates
browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    // Ignore if not a valid URL
    if (tabData.url && updatedData.status == "loading" && tabData.protocol != "safari-web-extension:") {
        
        // URL change check
        // updatedData.url is not available in old Safari
        if (savedTabURL[tabId] == tabData.url) { return; }
        savedTabURL[tabId] = tabData.url;
        
        // Send tab data to native app
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
            const cseData = JSON.parse(response);
            
            // type handler
            switch (cseData.type) {
                case "redirect":
                    browser.tabs.update(tabId, {url: cseData.redirectTo});
                    console.log("Redirecting...");
                    break;
                    
                case "postRedirect":
                    savedData[tabId] = cseData;
                    if (cseData.adv_ignorePOSTFallback) {
                        console.log("Waiting post_redirector... (ignore POST Fallback)");
                    } else {
                        browser.tabs.update(tabId, {url: postRedirectorURL});
                        console.log("Waiting post_redirector...");
                    }
                    break;
                    
                case "error":
                    console.log("Aborted due to an error.");
                    break;
                    
                case "cancel":
                    console.log("Operation canceled.");
                    break;

                default:
                    console.log("Received unknown type.");
                    break;
            }
        });
    }
});

// Handle post_redirector
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const tabId = sender.tab.id;
    if (request.type == "post_redirector") {
        if (savedData[tabId]) {
            console.log("[post_redirector] Redirecting... (with POST).");
            sendResponse(savedData[tabId]);
            delete savedData[tabId];
        } else if (sender.url == postRedirectorURL) {
            console.log("[post_redirector] No POST data. Going back...");
            sendResponse({type: "cancel"});
            browser.tabs.goBack(tabId);
        } else {
            console.log("[post_redirector] No POST data. Abort.");
            sendResponse({type: "cancel"});
        }
    }
});

// Handle tab removal
browser.tabs.onRemoved.addListener((tabId, removeInfo) => {
    delete savedData[tabId];
    delete savedTabURL[tabId];
});
