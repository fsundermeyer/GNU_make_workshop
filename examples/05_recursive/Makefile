#
# GNU make workshop
# Frank Sundermeyer 12.03.2015
#
# With contributions from:
# - Manuel Schnitzer (FORMAT check)
# - Thomas Hutterer (Statistics)
# - Joshua Schmid (Pattern rule for flac conversion)
#
# Example 05:
# Recursive conversion of a directory containing an arbitrary number of flac
# files in a structure like flac/<artist>/<album> (adjustable to any other
# structure by adjusting $(flac_files)
#

# Statistics
start_time := $(shell date +%s)

#-------------------------------------

FORMAT      := mp3
# Check if FORMAT contains a valid value
ifneq "$(FORMAT)" "$(filter $(FORMAT),mp3 ogg)"
  $(error Wrong FORMAT, needs to be "mp3" or "ogg")
endif

# Defaults
GAIN_METHOD := album 
FLAC_DIR    := flac
OUT_DIR    := $(FORMAT)
COVER_NAME  := cover
LAME_OPTS   := --preset extreme --pad-id3v2 --quiet
OGG_OPTS    := -Q -q 7

# File lists
flac_files  := $(wildcard $(FLAC_DIR)/**/**/*.flac)
lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(OUT_DIR)/%.$(FORMAT),$(flac_files))
lossy_dirs  := $(sort $(dir $(lossy_files)))
cover_fname := $(COVER_NAME).jpeg
cover_files := $(addsuffix $(cover_fname),$(lossy_dirs))
replaygains := $(addsuffix .replaygain,$(lossy_dirs))

# Programs
FFMPEG     := /usr/bin/ffmpeg
OGGENC     := /usr/bin/oggenc
MP3GAIN    := /usr/bin/mp3gain
VORBISGAIN := /usr/bin/vorbisgain
GLYRC      := /usr/bin/glyrc

# Statistics
file_count := $(words $(lossy_files))

# gain command 
ifeq "$(FORMAT)" "mp3"
  gain_cmd    := $(MP3GAIN) -c -q
else
  gain_cmd    := $(VORBISGAIN) -s -q 
endif
ifeq "$(strip $(GAIN_METHOD))" "album"
  ALBUM_GAIN := -a
else
  GAIN_METHOD := track
endif



#-------------------------------------

ifeq "$(FORMAT)" "mp3"
  define converter
    echo "mp3 conversion of $<"
    [[ -d $(dir $@) ]] || mkdir -p $(dir $@)
    $(FFMPEG) -i $< -qscale:a 0 -v quiet \
      -metadata REPLAYGAIN_REFERENCE_LOUDNESS=""\
      -metadata REPLAYGAIN_TRACK_GAIN="" \
      -metadata REPLAYGAIN_TRACK_PEAK="" \
      -metadata REPLAYGAIN_ALBUM_GAIN="" \
      -metadata REPLAYGAIN_ALBUM_PEAK="" \
      "$@"
  endef
else
  define converter
    echo "ogg conversion of $<"
    [[ -d $(dir $@) ]] || mkdir -p $(dir $@)
    $(OGGENC) $(OGG_OPTS) -o "$@" $<
  endef
endif

#-------------------------------------

.PHONY: all clean

all: $(lossy_files) $(replaygains) $(cover_files)
	@echo "--------------------"
	@echo "Converted $(file_count) flac files to $(FORMAT) in $$(($$(date +%s)-$(start_time))) seconds."

clean:
	rm -rf $(sort $(dir $(patsubst %/,%,$(lossy_dirs))))

$(OUT_DIR)/%.$(FORMAT): $(FLAC_DIR)/%.flac
	@$(converter)

$(OUT_DIR)/%/.replaygain: $(OUT_DIR)/%/*.$(FORMAT)
	@echo "$(strip Applying $(GAIN_METHOD) replay gain to $(dir $@))"
	@$(gain_cmd) $^ 2>&1 >/dev/null
	@touch $@

$(OUT_DIR)/%/$(cover_fname): $(FLAC_DIR)/%/*.flac
	  @if [ -f $(subst $(OUT_DIR),$(FLAC_DIR),$@) ]; then \
	    echo "Copying cover to $@"; \
	    cp $(subst $(OUT_DIR),$(FLAC_DIR),$@) $@; \
	  elif [ -f $(dir $(subst $(OUT_DIR),$(FLAC_DIR),$@))$(COVER_NAME).jpg ]; then \
	    echo "Copying cover to $@"; \
	    cp $(dir $(subst $(OUT_DIR),$(FLAC_DIR),$@))$(COVER_NAME).jpg $@; \
	  else \
	    echo "Fetching cover to $@"; \
	    $(GLYRC) cover \
	      --artist "$(shell metaflac --show-tag=ARTIST "$(firstword $<)" |sed 's/.*=//g')" \
	      --album "$(shell metaflac --show-tag=ALBUM "$(firstword $<)" |sed 's/.*=//g')" \
	      --write "$(dir $@)cover.:format:" \
	      --formats "jpeg" 2>/dev/null; \
	  fi
