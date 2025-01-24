browser.runtime.sendMessage({ type: "post_redirector" }, function(response) {
    if (response.length === 0) {
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
