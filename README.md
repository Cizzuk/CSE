# Customize Search Engine

Safari Extension to customize your search engine.  

**[Download on the App Store](https://apps.apple.com/app/customize-search-engine/id6445840140)**

[AltStore PAL Source](https://i.cizzuk.net/altstore/source.pal.json)

## Features

### Customize your Search Engine

Change Safari's default search engine.  
This is the most basic feature.

### CSE for Private Browse

Switch search engines in Private Browse.  

### Quick Search

Enter the keyword at the top to switch search engines.

Example:
- Search [`br something`](https://search.brave.com/search?q=something) to search in Brave Search
- Search [`wiki Safari`](https://en.wikipedia.org/w/index.php?title=Special:Search&search=Safari) to find Safari on Wikipedia
- Search [`yt Me at the zoo`](https://www.youtube.com/results?search_query=Me+at+the+zoo) to find the oldest videos on YouTube
- Search [`wbm example.com`](https://web.archive.org/web/*/example.com) to see past versions of the website

### Emoji Search

If you enter only one emoji, you can search on [Emojipedia.org](https://emojipedia.org).

### Switch Search Engines by Shortcuts and Focus

You can use a different custom search engine or disable CSE while at work, school, etc.

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

## License

This application is licensed under the [MIT License](https://github.com/Cizzuk/CSE/blob/main/LICENSE).

## Tip

Do you like it? please [send me a tip](https://cizzuk.net/tip/)!
