'use strict';
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let holdData = {};

// Detect tab updates
browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    
    // Ignore if not a valid URL
    if (tabData.url && tabData.status == "loading" && tabData.protocol != "safari-web-extension:") {
        
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
                    holdData[tabId] = cseData;
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
    if (request.type = "post_redirector") {
        if (holdData[tabId]) {
            console.log("[post_redirector] Redirecting... (with POST).");
            sendResponse(holdData[sender.tab.id]);
            delete holdData[tabId];
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
