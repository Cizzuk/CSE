browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
    if (response.length === 0 || response == "kill") {
        browser.runtime.sendMessage({ type: "goBack" });
        return;
    }
    
    // Create <form>
    var formDOM = '<form id="cseForm" method="post" action="' + response.redirectTo + '">';
    
    // Add POST Data
    response.postData.forEach(item => {
        formDOM += '<input type="hidden" name="' + item.key + '" value="' + item.value + '"></input>';
    })
    
    formDOM += '</form>';
    
    // Submit form
    document.getElementsByTagName("body")[0].innerHTML = formDOM;
    cseForm.submit();
});
