# Customize Search Engine

This is an extension to customize Safari's search engine.

It allows you to change to other search engines other than the default engines such as Google and Bing.

For example, you can change to a search engine such as Startpage, search within sites such as Wikipedia or GitHub, or use DeepL translation from the search bar.

## How it works

CSE works on pages from Safari's default search engines (Google, DuckDuckGo, etc.).  

It detects the special parameters in the URL when searching from Safari's search bar. (For example, Google has the parameter `client=safari` in its URL.)  

Then automatically redirects the page to your search engine.

### If the custom search engine has POST Data

CSE needs to create `<form method="post">` on the page to submit the form.  

Due to [CSP restrictions](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP), this will likely not work on Safari's default search engine, so first redirect to a local page generated by CSE (called `post_redirector.html`).

> [!IMPORTANT]
> I know this method is not available in macOS Safari, so this feature is disabled by default in CSE on macOS.  
> Therefore, if you set a search engine with strict CSP restrictions (such as DuckDuckGo) as the default for Safari, custom search engines with POST Data will not be available.

## Install

### App Store

[Download on the App Store](https://apps.apple.com/app/customize-search-engine/id6445840140)

## License

This software is licensed under the terms of the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/).

## Tip

Did you like it? [Send me a tip](https://cizzuk.net/en/tip/) if you like!
