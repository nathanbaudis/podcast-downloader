#!/usr/bin/env zsh -f

###########################################
# Script which downloads podcasts from an RSS feed
# Originally from: Timothy J. Luoma (https://gist.github.com/tjluoma/b4401b65df2505ff70778599fd6b7d27)
#
# Requires zsh for variable expnsion
###########################################


# Name of script (given by filename)
NAME="$0:t:r"

# RSS feed
FEED='http://feed.thisamericanlife.org/talpodcast'
# Output folder name, create it if it doesn't exist
DIR="$HOME/Media/Podcasts"
[[ ! -d "$DIR" ]] && mkdir -p "$DIR"

# Change into output directory
cd "$DIR"

# Error count
COUNT='0'

## Now we're going to check the feed for enclosures
## then we're going to look for lines
## that start with 'http' and end with 'mp3'

curl -sfLS "$FEED" \
| fgrep '<enclosure ' \
| tr '"|\047' '\012' \
| egrep '^http.*\.mp3$' \
| while read line
do
	URL="$line"
    echo "URL: $URL"

    # Get the filename from the tail of the URL
	FILENAME="$URL:t"

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
