'use strict';
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let savedData = {};
let savedTabURL = {};

// Detect tab updates
browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    // URL change check
    // updatedData.url is not available in old Safari
    if (savedTabURL[tabId] == tabData.url) { return; }
    savedTabURL[tabId] = tabData.url;
    
    // Ignore if not a valid URL
    if (tabData.url && tabData.status === "loading" && tabData.protocol !== "safari-web-extension:") {
        // Send tab data to native app
        browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
            const cseData = JSON.parse(response);
            
            // type handler
            switch (cseData.type) {
                case "redirect":
                    console.log(tabId, "Redirecting...");
                    browser.tabs.update(tabId, {url: cseData.redirectTo})
                    .then(() => { browser.tabs.sendMessage(tabId, {type: "showCurtain"}); })
                    .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                    break;
                    
                case "postRedirect":
                    savedData[tabId] = cseData;
                    if (cseData.adv_ignorePOSTFallback) {
                        console.log(tabId, "Waiting post_redirector... (ignorePOSTFallback)");
                        browser.tabs.sendMessage(tabId, {type: "showCurtain"});
                    } else {
                        console.log(tabId, "Redirecting to post_redirector.html...");
                        browser.tabs.update(tabId, {url: postRedirectorURL})
                        .then(() => {
                            console.log(tabId, "Waiting post_redirector...");
                            browser.tabs.sendMessage(tabId, {type: "showCurtain"});
                        })
                        .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                    }
                    break;
                    
                case "error":
                    console.log(tabId, "Aborted due to an error.");
                    break;
                    
                case "cancel":
                    console.log(tabId, "Operation canceled.");
                    break;

                default:
                    console.log(tabId, "Received unknown type.");
                    break;
            }
        });
    }
});

// Handle post_redirector
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const tabId = sender.tab.id;
    if (request.type === "post_redirector") {
        if (savedData[tabId]) {
            console.log(tabId, "[post_redirector]", "Redirecting... (with POST).");
            sendResponse(savedData[tabId]);
            delete savedData[tabId];
        } else if (sender.url === postRedirectorURL) {
            console.log(tabId, "[post_redirector]", " No POST data. Going back...");
            sendResponse({type: "cancel"});
            browser.tabs.goBack(tabId);
        } else {
            console.log(tabId, "[post_redirector]", " No POST data. Abort.");
            sendResponse({type: "cancel"});
        }
    }
});

// Handle tab removal
browser.tabs.onRemoved.addListener((tabId, removeInfo) => {
    delete savedData[tabId];
    delete savedTabURL[tabId];
});
