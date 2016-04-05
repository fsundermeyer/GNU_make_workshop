#
# GNU make workshop
# Frank Sundermeyer 27.02.2015
#
# Example 01:
# Simple conversion of a flac file to mp3 
# First try

mp3/song.mp3: song.flac mp3 mp3/cover.jpeg
	flac -s -d --stdout "song.flac" | lame --quiet \
	  --ta "Nine Inch Nails" \
	  --tl "The Slip" \
	  --tt "999,999" \
	  --ty "2008" \
	  --tc "" \
	  --tn "01" \
	  --tg "Alternative" \
	  - "mp3/song.mp3"

mp3/cover.jpeg: mp3
	glyrc cover \
	  --artist "Nine Inch Nails" \
	  --album "The Slip" \
	  --write "mp3/cover.:format:" \
	  --formats "jpeg" 2>/dev/null

mp3:
	mkdir -p mp3
