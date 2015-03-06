#
# GNU make training 03.2015
# Frank Sundermeyer 03.03.2015
#
# Example 02:
# Simple conversion of a flac file to mp3
# with all three rule types, variables, and vpath
#

# VPATH = flac
vpath %.flac flac

FLAC_FILE := song.flac
COVER     := mp3/cover.jpeg

mp3_file   := mp3/song.mp3
replaygain := mp3/.replaygain

.PHONY: all
all: $(mp3_file) $(COVER) $(replaygain)

$(mp3_file): $(FLAC_FILE) | mp3
	flac -s -d --stdout "$<" | lame --quiet \
	  --ta "Nine Inch Nails" \
	  --tl "The Slip" \
	  --tt "999,999" \
	  --ty "2008" \
	  --tc "" \
	  --tn "01" \
	  --tg "Alternative" \
	  - "$@"

$(COVER): $(mp3_file) | mp3
	glyrc cover \
	  --artist "Nine Inch Nails" \
	  --album "The Slip" \
	  --write "mp3/cover.:format:" \
	  --formats "jpeg" 2>/dev/null

$(replaygain): $(mp3_file)
	mp3gain -c -q -s i $<
	touch $@

mp3:
	mkdir $@
