'use strict';

// Check if webRequest API is available
const isWebRequestAvailable = browser.webRequest && browser.webRequest.onBeforeRequest;
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let savedData = {};
let incognitoStatus = {};
let processedUrls = {};

// Request handler (send tab data to native and handle response)
const requestHandler = (tabId, url, incognito, curtain = false) => {
    // Mark this URL was processed
    processedUrls[tabId] = url;
    
    // Easy URL checks
    if (!url) { return; }
    if (url.startsWith("safari-web-extension:")) { return; }
    if (!url.startsWith("https://")) { return; }
    
    // Prepare tab data to send
    const tabData = {
        url: url,
        incognito: incognito
    };
    
    // Send tab data to native app
    browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
        const cseData = JSON.parse(response);
        
        switch (cseData.type) {
            case "redirect":
                console.log(tabId, "Redirecting...");
                browser.tabs.update(tabId, {url: cseData.redirectTo})
                .then(() => {
                    if (curtain) { browser.tabs.sendMessage(tabId, {type: "showCurtain"}); }
                })
                .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                break;
                
            case "postRedirect":
                savedData[tabId] = cseData;

                console.log(tabId, "Redirecting to post_redirector.html...");
                browser.tabs.update(tabId, {url: postRedirectorURL})
                .then(() => { console.log(tabId, "Waiting post_redirector..."); })
                .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                
                if (curtain) { browser.tabs.sendMessage(tabId, {type: "showCurtain"}); }
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
};

// Detect tab updates
if (isWebRequestAvailable) {
    // If webRequest is available, use tabs.onUpdated for fallback and incognito status saving
    browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
        // Save tab incognito status if not already saved
        if (!incognitoStatus[tabId]) { incognitoStatus[tabId] = tabData.incognito; }

        if (processedUrls[tabId] === tabData.url) { return; }
        if (!tabData.url) { return; }
        if (updatedData.status !== "loading" && updatedData.url === undefined) { return; }

        requestHandler(tabId, tabData.url, tabData.incognito, true);
    });

} else {
    // If webRequest is not available, handle all via tabs.onUpdated
    browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
        if (processedUrls[tabId] === tabData.url) { return; }
        if (!tabData.url) { return; }
        if (tabData.status !== "loading") { return; }
        
        requestHandler(tabId, tabData.url, tabData.incognito, true);
    });
    console.log("webRequest API is not available, using tabs.onUpdated for all navigation detection");
}

// Detect web requests (only if webRequest API is available)
if (isWebRequestAvailable) {
    browser.webRequest.onBeforeRequest.addListener((details) => {
        const tabId = details.tabId;
        const url = details.url;
        
        if (details.type !== "main_frame") { return; }
        
        // Skip if tab incognito status is not available yet
        if (incognitoStatus[tabId] === undefined) { return; }
        
        requestHandler(tabId, url, incognitoStatus[tabId], false);
    });
}

// Handle post_redirector
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const tabId = sender.tab.id;
    if (request.type === "post_redirector") {
        if (savedData[tabId]) {
            console.log(tabId, "[post_redirector]", "Redirecting... (with POST).");
            sendResponse(savedData[tabId]);
            delete savedData[tabId];
        } else {
            console.log(tabId, "[post_redirector]", "No POST data. Cancel.");
        }
    }
});

// Detect tab removal
browser.tabs.onRemoved.addListener((tabId, removeInfo) => {
    delete savedData[tabId];
    delete incognitoStatus[tabId];
    delete processedUrls[tabId];
});
