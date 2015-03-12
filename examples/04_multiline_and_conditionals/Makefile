#
# GNU make training 03.2015
# Frank Sundermeyer 12.03.2015
#
# With contributions from:
# - Manuel Schnitzer
# - Thomas Hutterer
# - Joshua Schmid
#
# Example 04:
# Conversion of all flac files in a directory to mp3 or ogg
# with macroy and conditional make file parts
#

#-------------------------------------

FORMAT      := mp3

# Check if FORMAT contains a valid value
ifneq "$(FORMAT)" "$(filter $(FORMAT),mp3 ogg)"
  $(error Wrong FORMAT, needs to be "mp3" or "ogg")
endif

# Defaults
GAIN_METHOD := album 
FLAC_DIR   := flac
OUT_DIR    := $(FORMAT)
COVER_NAME := cover
LAME_OPTS  := --preset extreme --id3v2-only --pad-id3v2
OGG_OPTS   := -Q -q 7

# Targets
flac_files := $(wildcard $(FLAC_DIR)/*.flac)
cover_file  := $(OUT_DIR)/$(COVER_NAME).jpeg
replaygain  := $(OUT_DIR)/.replaygain
lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(OUT_DIR)/%.$(FORMAT),$(flac_files))

# Helper
flac_cover := $(firstword $(wildcard \
	          $(FLAC_DIR)/$(COVER_NAME).jpeg $(FLAC_DIR)/$(COVER_NAME).jpg))
album_artist := $(shell metaflac --show-tag=ARTIST \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')
album_title  := $(shell metaflac --show-tag=ALBUM \
                  "$(firstword $(flac_files))" |sed 's/.*=//g')

# Statistics
start_time := $(shell date +%s)
file_count := $(words $(lossy_files))

# gain command 
ifeq "$(FORMAT)" "mp3"
  gain_cmd    := mp3gain -c -q -s i
else
  gain_cmd    := vorbisgain -s -q 
endif
ifeq "$(GAIN_METHOD)" "album"
  gain_cmd += -a
else
  GAIN_METHOD := track
endif

#-------------------------------------

ifeq "$(FORMAT)" "mp3"
  define converter
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
else
  define converter
    echo "ogg conversion of $<"
    oggenc $(OGG_OPTS) -o $@ $<
  endef
endif

ifdef flac_cover
  define get_cover
	@echo "Copying cover"
	@cp $(flac_cover) $@
  endef
else
  define get_cover
	@echo "Fetching cover"
	@glyrc cover \
	  --artist "$(album_artist)" \
	  --album "$(album_title)" \
	  --write "$(OUT_DIR)/cover.:format:" \
	  --formats "jpeg" 2>/dev/null
  endef
endif


#-------------------------------------

.PHONY: all

all: $(lossy_files) $(cover_file) $(replaygain)
	@echo -e "--------------------\nConverted $(file_count) flac files to $(FORMAT) in $$(($$(date +%s)-$(start_time))) seconds."

$(OUT_DIR)/%.$(FORMAT): $(FLAC_DIR)/%.flac | $(OUT_DIR)
	@$(converter)

$(cover_file): $(flac_files) | $(OUT_DIR)
	@$(get_cover)

$(replaygain): $(lossy_files)
	@echo "Applying $(GAIN_METHOD) replay gain to $(OUT_DIR)"
	@$(gain_cmd) $< >/dev/null
	@touch $@

$(OUT_DIR):
	@mkdir $@
