browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    browser.runtime.sendNativeMessage("com.tsg0o0.cse.Extension", request, function(response) {
        const obj = JSON.parse(response);
        sendResponse(obj);
    });
    return true;
});
