#!/usr/bin/env zsh -f

# Arrays specifying for each podcast:
#   - RSS feed URL
#   - Option whether to get filenames from the title tag (1) or URL (0)
#   - Number of (most recent) episodes to download, -1 for no limit

declare -a FEED_URL_ARR=("http://feed.thisamericanlife.org/talpodcast" \
    "https://podcasts.files.bbci.co.uk/w13xttx2.rss")
declare -a FILENAME_FROM_TITLE_ARR=(1 1)
declare -a EPISODE_COUNT_ARR=(10 -1)
