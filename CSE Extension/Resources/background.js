'use strict';
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let holdData = {};
let tabState = {}; // tabId: "wait", "postRedirect", none

// Detect tab updates
browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    
    // Ignore if not a valid URL
    if (tabData.url && tabData.status == "loading" && tabData.protocol != "safari-web-extension:") {
        tabState[tabId] = "wait";
        
        // Send tab data to native app
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
            const cseData = JSON.parse(response);
            
            // type handler
            switch (cseData.type) {
                case "redirect":
                    delete tabState[tabId];
                    browser.tabs.update(tabId, {url: cseData.redirectTo});
                    console.log("Redirecting...");
                    break;
                    
                case "postRedirect":
                    holdData[tabId] = cseData;
                    tabState[tabId] = "postRedirect";
                    if (cseData.adv_ignorePOSTFallback) {
                        console.log("Waiting post_redirector... (ignore POST Fallback)");
                    } else {
                        browser.tabs.update(tabId, {url: postRedirectorURL});
                        console.log("Waiting post_redirector...");
                    }
                    break;
                    
                case "error":
                    delete tabState[tabId];
                    console.log("Aborted due to an error.");
                    break;
                    
                case "cancel":
                    delete tabState[tabId];
                    console.log("Operation canceled.");
                    break;

                default:
                    delete tabState[tabId];
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
        if (tabState[tabId] == "postRedirect") {
            console.log("[post_redirector] Redirecting... (with POST).");
            sendResponse(holdData[sender.tab.id]);
            delete holdData[sender.tab.id];
            delete tabState[tabId];
        } else if (tabState[tabId] == "wait") {
        } else if (sender.url == postRedirectorURL) {
            console.log("[post_redirector] No POST data. Going back...");
            sendResponse({type: "cancel"});
            browser.tabs.goBack(sender.tab.id);
        } else {
            console.log("[post_redirector] No POST data. Abort.");
            sendResponse({type: "cancel"});
        }
    }
});
