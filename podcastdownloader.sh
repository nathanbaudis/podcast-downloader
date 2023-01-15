#!/usr/bin/env zsh -f

###########################################
# Script which downloads podcasts from an RSS feed
# Originally from: Timothy J. Luoma (https://gist.github.com/tjluoma/b4401b65df2505ff70778599fd6b7d27)
#
# Requires zsh for variable expnsion
###########################################


##### Config
# RSS feed
FEED='http://feed.thisamericanlife.org/talpodcast'

# Output folder name, create it if it doesn't exist
DIR="$HOME/Media/Podcasts"
[[ ! -d "$DIR" ]] && mkdir -p "$DIR"

# Get filenames from title tags
FILENAME_FROM_TITLE=1
#####


# Name of script (given by filename)
NAME="$0:t:r"

# Change into output directory
cd "$DIR"

# Error count
COUNT='0'

# Remove linebreaks, then split items (feed entries) to their own lines
curl -sfLS "$FEED" \
| tr -d '\r' | tr '\n' ' ' \
| sed -e "s/&gt;/>/g" -e "s/&lt;/</g" \
| perl -pe 's/<item>(.*?)<\/item>/\1\n/g' \
| while read -r line
do
    # Get URL from enclosure tag, fix ampersand encoding for curl
    URL=$(printf '%s' "$line" | perl -pe 's/.*<enclosure url=\"(.*?)\".*/\1/g')
    URL=$(printf '%s' "$URL" | sed -e "s/\&amp;/\&/g")
    echo "URL: $URL"


    TITLE=$(printf '%s' "$line" | perl -pe 's/.*<title>(.*?)<\/title>.*/\1/g')

    if [[ $FILENAME_FROM_TITLE -eq 1 ]]
    then
        FILENAME="$TITLE"".mp3"
        # Remove colons from filename
        FILENAME=$(printf '%s' "$FILENAME" | sed -e "s/://g")
    else
        # Get the filename from the tail of the URL
        FILENAME="$URL:t:r"".mp3"
    fi

    # Check to see if file with name alredy exists
	if [[ -e "$FILENAME" ]]
	then
		echo "We already have '$PWD/$FILENAME'."
	else
        # Download the URL to the $FILENAME
		curl --output "$FILENAME" --silent --location --fail --show-error "$URL"

		EXIT="$?"

		if [[ "$EXIT" == "0" ]]
		then
			echo "Successfully downloaded '$URL' to '$PWD/$FILENAME'."
		else
            # Increment error count
			((COUNT++))
            # Print error and log to desktop
			echo "$0 failed to download '$URL' to '$PWD/$FILENAME' (\$EXIT = $EXIT)" \
			| tee -a "$HOME/Desktop/$0:t:r.errors.txt"
            
            # Move file to trash
			mv -vn "$FILENAME" "$HOME/.Trash/$FILENAME.$$.$RANDOM.mp3"
		fi
	fi
done

if [[ "$COUNT" == "0" ]]
then
	echo "$NAME finished with no errors"
elif [[ "$COUNT" == "1" ]]
then
	echo "$NAME finished with 1 error"
else
	echo "$NAME finished with $COUNT errors"
fi

exit 0
#
#EOF
