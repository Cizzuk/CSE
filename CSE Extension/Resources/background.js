'use strict';

// Check if webRequest API is available
const isWebRequestAvailable = browser.webRequest && browser.webRequest.onBeforeRequest;
const postRedirectorURL = location.protocol + "//" + location.host + "/post_redirector.html";

let savedData = {}; // Store data for post redirects
let incognitoStatus = {}; // Store incognito status for Private Seaerch Engine
let processedUrls = {}; // Store processed URLs to avoid duplicate processing

// Request handler (send tab data to native and handle response)
const requestHandler = async (tabId, url) => {
    // Mark this URL was processed
    processedUrls[tabId] = url;
    
    // Easy URL checks
    if (!url) { return; }
    if (url.startsWith("safari-web-extension:")) { return; }
    if (!url.startsWith("https://")) { return; }
    
    // Check incognito status
    if (incognitoStatus[tabId] === undefined) {
        incognitoStatus[tabId] = await getTabIncognitoStatus(tabId);
    }
    
    // Prepare tab data to send
    const tabData = {
        url: url,
        incognito: incognitoStatus[tabId]
    };
    
    // Send tab data to native app
    browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", tabData, function(response) {
        const cseData = JSON.parse(response);
        
        switch (cseData.type) {
            case "redirect":
                console.log(tabId, "Redirecting...");
                browser.tabs.update(tabId, {url: cseData.redirectTo})
                .catch((error) => { console.error(tabId, "Redirect failed:", error); });
                break;
                
            case "postRedirect":
                savedData[tabId] = cseData;

                console.log(tabId, "Redirecting to post_redirector.html...");
                browser.tabs.update(tabId, {url: postRedirectorURL})
                .then(() => { console.log(tabId, "Waiting post_redirector..."); })
                .catch((error) => { console.error(tabId, "Redirect failed:", error); });
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

const getTabIncognitoStatus = async (tabId) => {
    console.log(tabId, "Fetching incognito status...");
    let tabData = await browser.tabs.get(tabId);
    return tabData.incognito;
};

if (isWebRequestAvailable) {
    // Detect web requests
    browser.webRequest.onBeforeRequest.addListener((details) => {
        const tabId = details.tabId;
        const url = details.url;
        
        if (details.type !== "main_frame") { return; }
        
        requestHandler(tabId, url);
    });
} else {
    console.log("webRequest API is not available, using tabs.onUpdated for all navigation detection");
}

// Fallback: use tabs.onUpdated
browser.tabs.onUpdated.addListener((tabId, updatedData, tabData) => {
    // Save tab incognito status if not already saved
    if (incognitoStatus[tabId] === undefined) {
        incognitoStatus[tabId] = tabData.incognito;
    }
    
    if (processedUrls[tabId] === tabData.url) { return; }
    if (!tabData.url) { return; }
    if (tabData.status !== "loading") { return; }
    
    requestHandler(tabId, tabData.url);
});

// Detect tab creation
browser.tabs.onCreated.addListener((tabData) => {
    incognitoStatus[tabData.id] = tabData.incognito;
});

// Detect tab removal
browser.tabs.onRemoved.addListener((tabId, removeInfo) => {
    delete savedData[tabId];
    delete incognitoStatus[tabId];
    delete processedUrls[tabId];
});

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
