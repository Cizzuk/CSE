browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
    if (response == "kill") {
        document.getElementsByTagName("body")[0].innerHTML = '<h1>CSE</h1><p>An error occurred during redirect.</p><p>Please check your settings.</p><a href="net.cizzuk.cse://" target="_blank" rel="noopener noreferrer">Open CSE Settings</a>';
        return;
    } else if (response.length === 0) {
        window.history.go(-3);
        return;
    }
    
    // Create <form>
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = response.redirectTo;
    
    // Add POST Data
    response.postData.forEach(item => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = item.key;
        input.value = item.value;
        form.appendChild(input);
    })
    
    // Submit form
    document.body.appendChild(form);
    form.submit();
});
