#
# GNU make workshop
# Frank Sundermeyer 07.04.2016
#
# With contributions from:
# - Manuel Schnitzer (FORMAT check)
# - Joshua Schmid / Christoph Wickert (Pattern rule for flac conversion)
#
# Example 05:
# Recursive conversion of a directory containing an arbitrary number of flac
# files in a structure like flac/<artist>/<album> (adjustable to any other
# structure by adjusting $(flac_files)
#

SHELL = /bin/bash

# Statistics
start_time := $(shell date +%s)

#-------------------------------------
#  http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html
define rwildcard 
  $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
endef

#
# Usage is as follows. First, all C files in the current directory (or below).
# $(call rwildcard,,*.c)
# Then all C files in /tmp:
# $(call rwildcard,/tmp/,*.c)
# Multiple patterns can be used. Here are all C and H files:
# $(call rwildcard,/tmp/,*.c *.h)

#-------------------------------------

FORMAT      := mp3
# Check if FORMAT contains a valid value
ifneq "$(FORMAT)" "$(filter $(FORMAT),mp3 ogg)"
  $(error Wrong FORMAT, needs to be "mp3" or "ogg")
endif

# Defaults
GAIN_METHOD := album 
FLAC_DIR    := flac
OUT_DIR     := $(FORMAT)
COVER_NAME  := albumcover.jpg
LAME_OPTS   := --preset extreme --pad-id3v2 --quiet
OGG_OPTS    := -Q -q 7

# File lists

# Alternatives
#
# find:
# flac_files  := $(shell find -L $(FLAC_DIR) -name '*.flac')
#
# May need bash and extended globbing: SHELL=/bin/bash -O extglob -c
# flac_files  := $(wildcard $(FLAC_DIR)/**/**/*.flac)

flac_files  := $(call rwildcard,$(FLACDIR),*.flac)
lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(OUT_DIR)/%.$(FORMAT),$(flac_files))
lossy_dirs  := $(sort $(dir $(lossy_files)))
cover_files := $(addsuffix $(COVER_NAME),$(lossy_dirs))
replaygains := $(addsuffix .replaygain,$(lossy_dirs))

# Programs
FFMPEG     := /usr/bin/ffmpeg
OGGENC     := /usr/bin/oggenc
MP3GAIN    := /usr/bin/mp3gain
VORBISGAIN := /usr/bin/vorbisgain
GLYRC      := /usr/bin/glyrc

#-------------------------------------
# Define mp3/ogg conversion and gain commands
#

ifeq "$(FORMAT)" "mp3"
  # gain command 
  gain_cmd := $(MP3GAIN) -c -q
  # mp3 conversion 
  define converter
    $(FFMPEG) -i $< -qscale:a 0 -v quiet \
      -metadata REPLAYGAIN_REFERENCE_LOUDNESS=""\
      -metadata REPLAYGAIN_TRACK_GAIN="" \
      -metadata REPLAYGAIN_TRACK_PEAK="" \
      -metadata REPLAYGAIN_ALBUM_GAIN="" \
      -metadata REPLAYGAIN_ALBUM_PEAK="" \
      "$@"
  endef
else
  # gain command 
  gain_cmd := $(VORBISGAIN) -s -q
  # ogg conversion 
  converter = $(OGGENC) $(OGG_OPTS) -o "$@" $<
endif

# Album or track gain?
#
ifeq "$(strip $(GAIN_METHOD))" "album"
  gain_cmd += -a
else
  GAIN_METHOD := track
endif

#-------------------------------------

.PHONY: all clean

all: $(lossy_files) $(replaygains) $(cover_files)
	@echo "--------------------"
	@echo "Successfully converted flac files to $(FORMAT) in $$(($$(date +%s)-$(start_time))) seconds."

clean:
	rm -rf $(sort $(dir $(patsubst %/,%,$(lossy_dirs))))

$(FORMAT)/%.$(FORMAT): flac/%.flac
	@echo "$(FORMAT) conversion of $<"
	@[ -d $(@D) ] || mkdir -p $(@D)
	@$(converter)

# Prerequisite definition is questionable
#
%/.replaygain: %/*.$(FORMAT)
	@echo "$(strip Applying $(GAIN_METHOD) replay gain to $(@D))"
	@$(gain_cmd) $^ 2>&1 >/dev/null
	@touch $@

$(cover_files): FLAC_COVERDIR = $(subst $(OUT_DIR),$(FLAC_DIR),$(@D))
$(cover_files): FLAC_COVER = $(FLAC_COVERDIR)/$(COVER_NAME)
$(cover_files): FLAC_FILE = $(firstword $(wildcard $(FLAC_COVERDIR)/*.flac))
$(cover_files):
	@[ -d $(@D) ] || mkdir -p $(@D)
	@if [ -f $(FLAC_COVER) ]; then \
	    echo "Copying cover to $@"; \
	    cp $(FLAC_COVER) $@; \
	  else \
	    echo "Fetching cover for $@"; \
	    $(GLYRC) cover \
	      --artist "$(shell metaflac --show-tag=ARTIST "$(FLAC_FILE)" |sed 's/.*=//g')" \
	      --album "$(shell metaflac --show-tag=ALBUM "$(FLAC_FILE)" |sed 's/.*=//g')" \
	      --write "$@" \
	      --formats "jpeg" 2>/dev/null; \
	  fi
