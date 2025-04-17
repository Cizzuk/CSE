'use strict';
let holdData = [];
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";

browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    // If the URL is updated
    if (tabData.url && tabData.url != postRedirectorURL && tabData.url != "") {
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
            const cseData = JSON.parse(response);
            
            // type handler
            if (cseData.type == "redirect") {
                console.log("Run redirect.");
                browser.tabs.update(tabId, {url: cseData.redirectTo});
                browser.tabs.sendMessage(tabId, {type: "curtain"});
                
            } else if (cseData.type == "haspost") {
                holdData = cseData;
                if (!cseData.adv_ignorePOSTFallback) {
                    console.log("Open POST Redirector.");
                    browser.tabs.update(tabId, {url: postRedirectorURL});
                    browser.tabs.sendMessage(tabId, {type: "curtain"});
                }
                
            } else if (cseData.type == "error") {
                console.log("Aborted due to an error.");
                
            } else if (cseData.type == "cancel") {
                console.log("Operation canceled.");
                
            }

            return;
        });
    }
});

// POST Redirect
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.type == "goBack") {
        browser.tabs.goBack(sender.tab.id);
    } else if ((request.type == "post_redirector" || request.type == "content") && holdData.type == "haspost") {
        console.log("Run redirect (with POST).");
        sendResponse(holdData);
        holdData = [];
    } else {
        sendResponse("kill");
    }
});
