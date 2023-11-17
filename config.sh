#!/usr/bin/env zsh -f

# Output folder name
DIR="$HOME/Media/Podcasts"

# Arrays specifying for each podcast:
#   - RSS feed URL
#   - Option whether to download shownotes
#   - Option whether to get filenames from the title tag (1) or URL (0)
#   - Number of (most recent) episodes to download, -1 for no limit
#   - Option to prepend episode number to filename (if specified in feed) 

declare -a FEED_URL_ARR=("http://feed.thisamericanlife.org/talpodcast" \
    "https://podcasts.files.bbci.co.uk/w13xttx2.rss")
declare -a FILENAME_FROM_TITLE_ARR=(1 1)
declare -a DOWNLOAD_SHOWNOTES_ARR=(1 0)
declare -a EPISODE_COUNT_ARR=(10 -1)
declare -a PREPEND_EP_NUM_ARR=(0 0)
