FILES = $(patsubst %.md,%,$(wildcard *.md))

.PHONY: all
all: $(addsuffix -slide.html,$(FILES)) $(addsuffix .html,$(FILES))
$(foreach F,$(FILES),$(eval $(F)-slide.html:$(F).md))
$(foreach F,$(FILES),$(eval $(F).html:$(F).md))
%-slide.html: %.md header.html
	scholdoc $< -f markdown_scholarly -t revealjs -V theme=night -H header.html -s --self-contained -o $@
%.html: %.md header.html
	scholdoc $< -f markdown_scholarly -H header.html -s --self-contained -o $@
