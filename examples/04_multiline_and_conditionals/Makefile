#
# GNU make training 03.2015
# Frank Sundermeyer 06.03.2015
#
# Example 04:
# Conversion of all flac files in a directory to mp3 or ogg
# with macroy and conditional make file parts
#

#-------------------------------------

FORMAT      := mp3
GAIN_METHOD := album 

FLAC_DIR   := flac
MP3_DIR    := mp3
OGG_DIR    := ogg
COVER_NAME := cover
LAME_OPTS  := --preset extreme --id3v2-only --pad-id3v2
OGG_OPTS   := -Q -q 7

flac_files := $(wildcard $(FLAC_DIR)/*.flac)
flac_cover := $(firstword $(wildcard \
	          $(FLAC_DIR)/$(COVER_NAME).jpeg $(FLAC_DIR)/$(COVER_NAME).jpg))
album_artist := $(shell metaflac --show-tag=ARTIST \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')
album_title  := $(shell metaflac --show-tag=ALBUM \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')

ifeq "$(FORMAT)" "mp3"
  lossy_files := $(patsubst flac/%.flac,$(MP3_DIR)/%.mp3,$(flac_files))
  lossy_dir   := $(MP3_DIR)
  cover_file  := $(MP3_DIR)/$(COVER_NAME).jpeg
  replaygain  := $(MP3_DIR)/.replaygain
  gain_cmd    := mp3gain -c -q -s i
else
  lossy_files := $(patsubst flac/%.flac,$(OGG_DIR)/%.ogg,$(flac_files))
  lossy_dir   := $(OGG_DIR)
  cover_file  := $(OGG_DIR)/$(COVER_NAME).jpeg
  replaygain  := $(OGG_DIR)/.replaygain
  gain_cmd    := vorbisgain -s -q 
endif

ifeq "$(GAIN_METHOD)" "album"
  gain_cmd += -a
else
  GAIN_METHOD := track
endif

#-------------------------------------

define flac2mp3
  echo "mp3 conversion of $<"
  flac -s -d --stdout "$<" | lame --quiet $(LAME_OPTS) \
    --ta "$(album_artist)" \
    --tl "$(album_title)" \
    --tt "$(shell metaflac --show-tag=TITLE "$<" |sed 's/.*=//g')" \
    --ty "$(shell metaflac --show-tag=DATE "$<" |sed 's/.*=//g')" \
    --tc "$(shell metaflac --show-tag=COMMENT "$<" |sed 's/.*=//g')" \
    --tg "$(shell metaflac --show-tag=GENRE "$<" |sed 's/.*=//g')" \
    --tn "$(shell metaflac --show-tag=TRACKNUMBER "$<" |sed 's/.*=//g')" \
    - "$@"
endef

define flac2ogg
  echo "ogg conversion of $<"
  oggenc $(OGG_OPTS) -o $@ $<
endef

#-------------------------------------

vpath %.flac flac

.PHONY: all

all: $(lossy_files) $(cover_file) $(replaygain)

mp3/%.mp3: %.flac | $(lossy_dir)
	@$(flac2mp3)

ogg/%.ogg: %.flac | $(lossy_dir)
	@$(flac2ogg)

$(cover_file): $(lossy_files) | $(lossy_dir)
ifdef flac_cover
	@echo "Copying cover"
	@cp $(flac_cover) $@
else
	@echo "Fetching cover"
	@glyrc cover \
	  --artist "$(album_artist)" \
	  --album "$(album_title)" \
	  --write "$(lossy_dir)/cover.:format:" \
	  --formats "jpeg" 2>/dev/null
endif

$(replaygain): $(lossy_files)
	@echo "Applying $(GAIN_METHOD) replay gain to $(lossy_dir)"
	@$(gain_cmd) $< >/dev/null
	@touch $@

$(lossy_dir):
	@mkdir $@
