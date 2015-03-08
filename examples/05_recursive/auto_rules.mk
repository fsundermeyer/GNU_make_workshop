#
# GNU make training 03.2015
# Frank Sundermeyer 03.03.2015
#
# Example 03:
# Simple conversion of a flac file to mp3
# with functions and patterns
#

# http://blog.jgc.org/2012/01/using-gnu-makes-define-and-eval-to.html

FORMAT      := mp3

FLAC_DIR   := flac
MP3_DIR    := mp3
OGG_DIR    := ogg
COVER_NAME := cover
LAME_OPTS  := --preset extreme --id3v2-only --pad-id3v2 --quiet
OGG_OPTS   := -Q -q 7

flac_files := $(wildcard $(FLAC_DIR)/**/**/*.flac)
flac_dirs  := $(sort $(dir $(flac_files)))

#-------------------
# MP3 recipe and rule
#
ifeq "$(FORMAT)" "mp3"
  lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(MP3_DIR)/%.mp3,$(flac_files))
  define flac2lossy
	@echo "mp3 conversion of $$<"
	@flac -s -d --stdout "$$<" | lame $(LAME_OPTS) \
	  --ta "$$(shell metaflac --show-tag=ARTIST "$$<" |sed 's/.*=//g')" \
	  --tl "$$(shell metaflac --show-tag=ALBUM "$$<" |sed 's/.*=//g')" \
	  --tt "$$(shell metaflac --show-tag=TITLE "$$<" |sed 's/.*=//g')" \
	  --ty "$$(shell metaflac --show-tag=DATE "$$<" |sed 's/.*=//g')" \
	  --tc "$$(shell metaflac --show-tag=COMMENT "$$<" |sed 's/.*=//g')" \
	  --tg "$$(shell metaflac --show-tag=GENRE "$$<" |sed 's/.*=//g')" \
	  --tn "$$(shell metaflac --show-tag=TRACKNUMBER "$$<" |sed 's/.*=//g')" \
	  - "$$@"
  endef
  define lossy_rules
    $(1)%.mp3: %.flac | $(1)
	$(flac2lossy)
  endef
#--------------------
# OGG recipe and rule
#
else
  lossy_files := $(patsubst $(FLAC_DIR)/%.flac,$(OGG_DIR)/%.ogg,$(flac_files))
  define flac2lossy
	@echo "ogg conversion of $$<"
	@oggenc $(OGG_OPTS) -o "$$@" $$<
  endef
  define lossy_rules
    $(1)%.ogg: %.flac | $(1)
	$(flac2lossy)
  endef
endif

lossy_dirs  :=  $(sort $(dir $(lossy_files)))
cover_files :=  $(addsuffix $(COVER_NAME).jpeg,$(lossy_dirs))

#--------------------------------------------------------

vpath %.flac $(flac_dirs)

.PHONY: all
all: $(lossy_files)

#--------------------
# Generate pattern rules %.mp3: %.flac or %.ogg: flac for all mp3/ogg
# target directories
#
$(foreach dir,$(lossy_dirs),$(eval $(call lossy_rules,$(dir))))

#--------------------
# Create directories
#
$(lossy_dirs):
	@mkdir -p $@
