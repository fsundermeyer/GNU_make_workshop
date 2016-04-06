#
# GNU make workshop
# Frank Sundermeyer 03.03.2015
#
# Example 03:
# Conversion of all flac files in a directory to mp3
# with functions and patterns
#

#-------------------------------------

FLAC_DIR   := flac
MP3_DIR    := mp3
COVER      := cover

flac_files := $(wildcard $(FLAC_DIR)/*.flac)
mp3_files  := $(patsubst $(FLAC_DIR)/%.flac,$(MP3_DIR)/%.mp3,$(flac_files))
cover_file := $(MP3_DIR)/$(COVER_NAME).jpeg
replaygain := $(MP3_DIR)/.replaygain

album_artist := $(shell metaflac --show-tag=ARTIST \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')
album_title  := $(shell metaflac --show-tag=ALBUM \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')

#-------------------------------------


.PHONY: all
all: $(mp3_files) $(cover_file) $(replaygain)

$(MP3_DIR)/%.mp3: $(FLAC_DIR)/%.flac | $(MP3_DIR)
	ffmpeg -i $< -qscale:a 0 -v quiet "$@"

$(cover_file): $(flac_files) | $(MP3_DIR)
	glyrc cover \
	  --artist "$(album_artist)" \
	  --album "$(album_title)" \
	  --write "$(MP3_DIR)/$(COVER).:format:" \
	  --formats "jpeg" 2>/dev/null

$(replaygain): $(mp3_files)
	mp3gain -c -q -s i $^ >/dev/null
	touch $@

$(MP3_DIR):
	mkdir -p $@
