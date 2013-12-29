ALL := style.css guide.js

.PHONY: all clean

all: $(ALL)

%.js: %.coffee
	coffee --compile --output $(@D) $<

%.css: %.sass
	sass $< $@

clean:
	rm -f $(ALL)
