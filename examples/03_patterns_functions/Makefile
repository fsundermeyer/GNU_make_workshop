#
# GNU make training 03.2015
# Frank Sundermeyer 03.03.2015
#
# Example 03:
# Conversion of all flac files in a directory to mp3
# with functions and patterns
#

#-------------------------------------

FLAC_DIR   := flac
MP3_DIR    := mp3
COVER_NAME := cover

flac_files := $(wildcard $(FLAC_DIR)/*.flac)
mp3_files  := $(patsubst flac/%.flac,$(MP3_DIR)/%.mp3,$(flac_files))
cover_file := $(MP3_DIR)/$(COVER_NAME).jpeg
replaygain := $(MP3_DIR)/.replaygain

album_artist := $(shell metaflac --show-tag=ARTIST \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')
album_title  := $(shell metaflac --show-tag=ALBUM \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')

#-------------------------------------

vpath %.flac flac

.PHONY: all
all: $(mp3_files) $(cover_file) $(replaygain)

mp3/%.mp3: %.flac | $(MP3_DIR)
	flac -s -d --stdout "$<" | lame --quiet \
	  --ta "$(album_artist)" \
	  --tl "$(album_title)" \
	  --tt "$(shell metaflac --show-tag=TITLE "$<" |sed 's/.*=//g')" \
	  --ty "$(shell metaflac --show-tag=DATE "$<" |sed 's/.*=//g')" \
	  --tc "$(shell metaflac --show-tag=COMMENT "$<" |sed 's/.*=//g')" \
	  --tg "$(shell metaflac --show-tag=GENRE "$<" |sed 's/.*=//g')" \
	  --tn "$(shell metaflac --show-tag=TRACKNUMBER "$<" |sed 's/.*=//g')" \
	  - "$@"

$(cover_file): $(mp3_files) | $(MP3_DIR)
	glyrc cover \
	  --artist "$(album_artist)" \
	  --album "$(album_title)" \
	  --write "$(MP3_DIR)/cover.:format:" \
	  --formats "jpeg" 2>/dev/null

$(replaygain): $(mp3_files)
	mp3gain -c -q -s i $< >/dev/null
	touch $@

$(MP3_DIR):
	mkdir $@
