SCRIPTS := guide.js settings.js
STYLES := style.css

ALL := $(SCRIPTS) $(STYLES)

.PHONY: all min clean channels channels.js

all: $(ALL)

%.js: %.coffee
	coffee --compile --output $(@D) $<

%.css: %.sass
	sass $< $@

min: $(patsubst %,%.min,$(ALL))
	@for s in $(ALL); do \
		echo "$$s.min -> $$s"; \
		mv $$s.min $$s; \
	done

%.js.min: %.js
	closure-compiler --js $< --js_output_file $@

%.css.min: %.css
	curl -X POST -s --data-urlencode input@$< http://cssminifier.com/raw > $@

channels: channels.js
channels.js:
	wget -O $@ http://www.tvgids.nl/json/lists/channels.php
	echo window.CHANNELS=`cat $@` > $@

clean:
	rm -f $(ALL)
