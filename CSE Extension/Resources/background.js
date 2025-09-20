'use strict';
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";
let savedData = {};
let savedTabIncognito = {};

// Check if webRequest API is available
const isWebRequestAvailable = browser.webRequest && browser.webRequest.onBeforeRequest;

// Request handler (send tab data to native and handle response)
const requestHandler = (tabId, url, incognito, curtain = false) => {
    // Easy URL checks
    if (url === "") { return; }
    if (url.startsWith("safari-web-extension:")) { return; }
    if (!url.startsWith("https://")) { return; }
    
    // Prepare tab data
    const tabData = {
        url: url,
        incognito: incognito
    };
    
    // Send tab data to native app
    browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
        const cseData = JSON.parse(response);
        
        // type handler
        switch (cseData.type) {
            case "redirect":
                console.log(tabId, "Redirecting...");
                browser.tabs.update(tabId, {url: cseData.redirectTo})
                .then(() => {
                    // Show curtain if needed
                    if (curtain) { browser.tabs.sendMessage(tabId, {type: "showCurtain"}); }
                })
                .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                break;
                
            case "postRedirect":
                savedData[tabId] = cseData;
                
                if (cseData.adv_ignorePOSTFallback) {
                    console.log(tabId, "Waiting post_redirector... (ignorePOSTFallback)");
                } else {
                    console.log(tabId, "Redirecting to post_redirector.html...");
                    browser.tabs.update(tabId, {url: postRedirectorURL})
                    .then(() => { console.log(tabId, "Waiting post_redirector..."); })
                    .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                }
                
                // Show curtain if needed
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
if (!isWebRequestAvailable) {
    // If webRequest is not available, handle all via tabs.onUpdated
    browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
        if (tabData.url && tabData.status === "loading") {
            requestHandler(tabId, tabData.url, tabData.incognito, true);
        }
    });
    console.log("webRequest API is not available, using tabs.onUpdated for all navigation detection");
} else {
    // If webRequest is available, use tabs.onUpdated for fallback and incognito status saving
    browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
        const wasTabDataSaved = savedTabIncognito[tabId] !== undefined;
        
        // Only send request if tab data was not previously saved
        if (!wasTabDataSaved && tabData.url && tabData.status === "loading") {
            requestHandler(tabId, tabData.url, tabData.incognito, true);
        }
        
        // Save incognito status if not already saved
        if (!wasTabDataSaved) { savedTabIncognito[tabId] = tabData.incognito; }
    });
}

// Detect web requests (only if webRequest API is available)
if (isWebRequestAvailable) {
    browser.webRequest.onBeforeRequest.addListener((details) => {
        const tabId = details.tabId;
        const url = details.url;
        
        // Skip if not a main frame request
        if (details.type !== "main_frame") { return; }
        
        // Skip if tab data is not available yet
        if (savedTabIncognito[tabId] === undefined) { return; }
        
        // Send request
        requestHandler(tabId, url, savedTabIncognito[tabId], false);
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
    delete savedTabIncognito[tabId];
});
