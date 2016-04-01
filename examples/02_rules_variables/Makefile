#
# GNU make workshop
# Frank Sundermeyer 03.03.2015
#
# Example 02:
# Simple conversion of a flac file to mp3
# with all three rule types, variables, and vpath
#

FLAC_DIR := flac
MP3_DIR  := mp3
COVER    := cover

flac_file  := $(FLAC_DIR)/song.flac
cover_file := $(MP3_DIR)/$(COVER).jpeg
mp3_file   := $(MP3_DIR)/song.mp3
replaygain := $(MP3_DIR)/.replaygain

.PHONY: all
all: $(mp3_file) $(cover_file) $(replaygain)

$(mp3_file): $(flac_file) | $(MP3_DIR)
	flac -s -d --stdout "$<" | lame --quiet \
	  --ta "Nine Inch Nails" \
	  --tl "The Slip" \
	  --tt "999,999" \
	  --ty "2008" \
	  --tc "" \
	  --tn "01" \
	  --tg "Alternative" \
	  - "$@"

$(cover_file): $(flac_file) | $(MP3_DIR)
	glyrc cover \
	  --artist "Nine Inch Nails" \
	  --album "The Slip" \
	  --write "$(MP3_DIR)/$(COVER).:format:" \
	  --formats "jpeg" 2>/dev/null

$(replaygain): $(mp3_file)
	mp3gain -c -q -s i $<
	touch $@

$(MP3_DIR):
	mkdir $@
