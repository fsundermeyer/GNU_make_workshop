#
# GNU make training 03.2015
# Frank Sundermeyer 08.03.2015
#
# Example 05:
# Recursive conversion of a directory containing an arbitrary number of flac
# files in a structure like flac/<artist>/<album> (adjustable to any other
# structure by adjusting $(flac_files)
#

#-------------------------------------

FORMAT      := mp3
GAIN_METHOD := album 

FLAC_DIR   := flac
MP3_DIR    := mp3
OGG_DIR    := ogg
COVER_NAME := cover
LAME_OPTS  := --preset extreme --pad-id3v2 --quiet
OGG_OPTS   := -Q -q 7

flac_files := $(wildcard $(FLAC_DIR)/**/**/*.flac)

ifeq "$(FORMAT)" "mp3"
  lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(MP3_DIR)/%.mp3,$(flac_files))
else
  lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(OGG_DIR)/%.ogg,$(flac_files))
endif

lossy_dirs  := $(sort $(dir $(lossy_files)))
cover_files := $(addsuffix $(COVER_NAME).jpeg,$(lossy_dirs))
replaygains  := $(addsuffix .replaygain,$(lossy_dirs))

ifeq "$(strip $(GAIN_METHOD))" "album"
  ALBUM_GAIN := -a
else
  GAIN_METHOD := track
endif

#-------------------------------------

define flac2mp3
  echo "mp3 conversion of $<"
  [[ -d $(dir $@) ]] || mkdir -p $(dir $@)
  flac -s -d --stdout "$<" | lame $(LAME_OPTS) \
    --ta "$(shell metaflac --show-tag=ARTIST "$<" |sed 's/.*=//g')" \
    --tl "$(shell metaflac --show-tag=ALBUM "$<" |sed 's/.*=//g')" \
    --tt "$(shell metaflac --show-tag=TITLE "$<" |sed 's/.*=//g')" \
    --ty "$(shell metaflac --show-tag=DATE "$<" |sed 's/.*=//g')" \
    --tc "$(shell metaflac --show-tag=COMMENT "$<" |sed 's/.*=//g')" \
    --tg "$(shell metaflac --show-tag=GENRE "$<" |sed 's/.*=//g')" \
    --tn "$(shell metaflac --show-tag=TRACKNUMBER "$<" |sed 's/.*=//g')" \
    - "$@"
endef

define flac2ogg
  echo "ogg conversion of $<"
  [[ -d $(dir $@) ]] || mkdir -p $(dir $@)
  oggenc $(OGG_OPTS) -o $@ $<
endef

# Parameter 1: MP3_DIR / OGG_DIR
define cover
  @if [ -f $(subst $(1),$(FLAC_DIR),$@) ]; then \
    echo "Copying cover"; \
    cp $(subst $(1),$(FLAC_DIR),$@) $@; \
  elif [ -f $(dir $(subst $(1),$(FLAC_DIR),$@))$(COVER_NAME).jpg ]; then \
    echo "Copying cover"; \
    cp $(dir $(subst $(1),$(FLAC_DIR),$@))$(COVER_NAME).jpg $@; \
  else \
    echo "Fetching cover"; \
    glyrc cover \
      --artist "$(shell metaflac --show-tag=ARTIST "$(subst $(1),$(FLAC_DIR),$<)" |sed 's/.*=//g')" \
      --album "$(shell metaflac --show-tag=ALBUM "$(subst $(1),$(FLAC_DIR),$<)" |sed 's/.*=//g')" \
      --write "$(dir $@)cover.:format:" \
      --formats "jpeg" 2>/dev/null; \
  fi
endef

#-------------------------------------

.PHONY: all

all: $(lossy_files) $(replaygains) $(cover_files)

$(MP3_DIR)/%.mp3: $(FLAC_DIR)/%.flac
	@$(flac2mp3)

$(OGG_DIR)/%.ogg:$(FLAC_DIR)/%.flac
	@$(flac2ogg)

$(MP3_DIR)/%/.replaygain: $(MP3_DIR)/%/*.mp3
	@echo "Applying $(GAIN_METHOD) replay gain to $(dir $@)"
	@mp3gain -c -q -s i $(ALBUM_GAIN) $(dir $@)*.mp3 >/dev/null
	@touch $@

$(OGG_DIR)/%/.replaygain: $(OGG_DIR)/%/*.ogg
	@echo "Applying $(GAIN_METHOD) replay gain to $(dir $@)"
	@vorbisgain -s -q $(ALBUM_GAIN) $(dir $@)*.ogg >/dev/null
	@touch $@

$(MP3_DIR)/%/$(COVER_NAME).jpeg: $(FLAC_DIR)/%/*.flac
	$(call cover,$(MP3_DIR))

$(OGG_DIR)/%/$(COVER_NAME).jpeg: $(FLAC_DIR)/%/*.flac
	$(call cover,$(OGG_DIR))
