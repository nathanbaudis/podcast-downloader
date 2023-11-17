# Podcast downloader

Shell script to download podcasts. Based on [script by Timothy J. Luoma](https://gist.github.com/tjluoma/b4401b65df2505ff70778599fd6b7d27) with additional features:
- Supports multiple podcasts, downloaded to subdirectories
- Downloads shownotes to markdown files
- Option to specify a number of most recent episodes to be downloaded per podcast
- Option to set filenames based on episode titles instead of URLs (with modern tracking URLs, there is often no way to obtain a sensible filename from the URL)
- Option to prepend episode number to filename, if specified in feed

The top-level download folder, podcast RSS feeds and the mentioned options (on a per-episode basis) can be configured in `config.sh`.

Requirements include:
- zsh
- perl
- pandoc

Note that the script requires the zsh shell for variable expansion; it could however be modified to work with bash. While Regex is used to parse the HTML in lieu of a proper HTML parser, this is sufficient for the limited scope of RSS feeds.
