#!/usr/bin/env zsh -f

###########################################
# Script which downloads podcasts from an RSS feed
# Originally from: Timothy J. Luoma (https://gist.github.com/tjluoma/b4401b65df2505ff70778599fd6b7d27)
#
# Requires zsh for variable expnsion
###########################################


##### Config
# Output folder name
DIR="$HOME/Media/Podcasts"

# Define arrays with config options for each podcast
. ./config.sh
#####


# Name of script (given by filename)
NAME="$0:t:r"

# Create output folder if it doesn't exist
[[ ! -d "$DIR" ]] && mkdir -p "$DIR"

# Error count
ERR_COUNT='0'


# Iterate over podcasts
for ((i=1; i<${#FEED_URL_ARR[@]}+1; ++i))
do
    # Get config options
    FEED_URL=${FEED_URL_ARR[i]}
    FILENAME_FROM_TITLE=${FILENAME_FROM_TITLE_ARR[i]}
    EPISODE_COUNT=${EPISODE_COUNT_ARR[i]}

    # Raw feed without linebreaks
    FEED=$(curl -sfLS "$FEED_URL" \
    | tr -d '\r' | tr '\n' ' ' \
    | sed -e "s/&gt;/>/g" -e "s/&lt;/</g")

    # Get podcast title from first title tag (outside of an item)
    PODCAST_TITLE=$(printf '%s' "$FEED"  \
    | perl -pe 'print $1 and last if /.*?<title>(.*?)<\/title>.*?<item>/')

    # Create podcast subfolder if it doesn't exist and change into it
    DIR_PODCAST="$DIR/$PODCAST_TITLE"
    [[ ! -d "$DIR_PODCAST" ]] && mkdir -p "$DIR_PODCAST"
    cd "$DIR_PODCAST"

    echo "\nWorking on $PODCAST_TITLE"

    # Episode counter
    COUNT=1

    # Split items (feed entries) to their own lines and iterate over them
    printf '%s' "$FEED" \
    | perl -pe 's/<item>(.*?)<\/item>/\1\n/g' \
    | while read -r line
    do
        # Continue if specified episode number has been reached 
        if [[ EPISODE_COUNT -ge 0 && COUNT -gt EPISODE_COUNT ]]
        then
            continue
        fi
        COUNT=$((COUNT+1))

        # Get URL from enclosure tag, fix ampersand encoding for curl
        URL=$(printf '%s' "$line" | perl -pe 's/.*<enclosure url=\"(.*?)\".*/\1/g')
        URL=$(printf '%s' "$URL" | sed -e "s/\&amp;/\&/g")
        echo "URL: $URL"

        # Get episode title and fix apostrophe encoding
        TITLE=$(printf '%s' "$line" | perl -pe 's/.*<title>(.*?)<\/title>.*/\1/g')
        TITLE=$(printf '%s' "$TITLE" | sed -e "s/\&#039;/'/g")
        echo "TITLE: $TITLE"

        # Determine filename from feed URL or episode title
        if [[ $FILENAME_FROM_TITLE -eq 1 ]]
        then
            FILENAME="$TITLE"
            # Remove colons from filename
            FILENAME=$(printf '%s' "$FILENAME" | sed -e "s/://g")
        else
            # Get the filename from the tail of the URL
            FILENAME="$URL:t:r"
        fi
        FILENAME_MP3="$FILENAME"".mp3"
        FILENAME_MD="$FILENAME"".md"

        # Check to see if file with name alredy exists
        if [[ -e "$FILENAME_MP3" ]]
        then
            echo "We already have '$PWD/$FILENAME_MP3'."
        else
            # Shownotes
            NOTES=$(printf '%s' "$line" | perl -ne 'print $1 if /.*<content:encoded>(.*?)<\/content:encoded>.*/')

            # If the content:encoded field is empty, use the description
            if [[ $NOTES == "" ]]
            then
                DESCRIPTION=$(printf '%s' "$line" | perl -ne 'print $1 if /.*<description>(.*?)<\/description>.*/')
                NOTES=$DESCRIPTION
            fi

            # Convert shownotes to markdown using pandoc and save to file
            if [[ "$NOTES" != "" ]]
            then
                # Remove CDATA enclosure if it exists
                NOTES=$(printf '%s' "$NOTES" | perl -pe 's/.*<!\[CDATA\[(.*?)\]\]>.*/\1/g')
                printf '%s' "$NOTES" | pandoc -f html -t markdown -o "$FILENAME_MD"
            fi

            # Download the URL to the MP3 filename
            curl --output "$FILENAME_MP3" --silent --location --fail --show-error "$URL"

            EXIT="$?"

            if [[ "$EXIT" == "0" ]]
            then
                echo "Successfully downloaded '$URL' to '$PWD/$FILENAME_MP3'."
            else
                # Increment error count
                ((ERR_COUNT++))
                # Print error and log to desktop
                echo "$0 failed to download '$URL' to '$PWD/$FILENAME_MP3' (\$EXIT = $EXIT)" \
                | tee -a "$HOME/Desktop/$0:t:r.errors.txt"
                
                # Move file to trash
                mv -vn "$FILENAME_MP3" "$HOME/.Trash/$FILENAME_MP3.$$.$RANDOM.mp3"
            fi
        fi
    done # End of episode iteration
done # End of podcast iteration


if [[ "$ERR_COUNT" == "0" ]]
then
	echo "$NAME finished with no errors"
elif [[ "$ERR_COUNT" == "1" ]]
then
	echo "$NAME finished with 1 error"
else
	echo "$NAME finished with $ERR_COUNT errors"
fi

exit 0
#
#EOF
