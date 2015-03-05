#
# GNU make training 03.2015
# Frank Sundermeyer 03.03.2015
#
# Example 03:
# Simple conversion of a flac file to mp3
# with functions and patterns
#

# VPATH = flac
vpath %.flac flac

FLAC_FILES := $(wildcard flac/*.flac)
MP3_FILES  := $(patsubst flac/%.flac,mp3/%.mp3,$(FLAC_FILES))
COVER      := mp3/cover.jpeg

ALBUM_ARTIST := $(shell metaflac --show-tag=ARTIST \
                  "$(firstword $(FLAC_FILES))" |sed 's/.*=//g')
ALBUM_TITLE  := $(shell metaflac --show-tag=ALBUM \
                  "$(firstword $(FLAC_FILES))" |sed 's/.*=//g')

rgain     := mp3/.replaygain

.PHONY: all
all: $(MP3_FILES) $(COVER) $(rgain)

mp3/%.mp3: %.flac | mp3
	flac -s -d --stdout "$<" | lame --quiet \
	  --ta "$(ALBUM_ARTIST)" \
	  --tl "$(ALBUM_TITLE)" \
	  --tt "$(shell metaflac --show-tag=TITLE "$<" |sed 's/.*=//g')" \
	  --ty "$(shell metaflac --show-tag=DATE "$<" |sed 's/.*=//g')" \
	  --tc "$(shell metaflac --show-tag=COMMENT "$<" |sed 's/.*=//g')" \
	  --tg "$(shell metaflac --show-tag=GENRE "$<" |sed 's/.*=//g')" \
	  --tn "$(shell metaflac --show-tag=TRACKNUMBER "$<" |sed 's/.*=//g')" \
	  - "$@"

$(COVER): | mp3
	glyrc cover \
	  --artist "$(ALBUM_ARTIST)" \
	  --album "$(ALBUM_TITLE)" \
	  --write "mp3/cover.:format:" \
	  --formats "jpeg" 2>/dev/null

$(rgain): $(MP3_FILES)
	mp3gain -r -c mp3/*.mp3 >/dev/null
	touch mp3/.replaygain

mp3:
	mkdir mp3
