ALL := style.css guide.js settings.js

.PHONY: all clean

all: $(ALL)

%.js: %.coffee
	coffee --compile --output $(@D) $<

%.css: %.sass
	sass $< $@

clean:
	rm -f $(ALL)
