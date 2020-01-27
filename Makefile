name = praxis
version = 20200121

prefix ?= 
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
localstatedir ?= $(prefix)/var

libdir := $(libdir)/$(name)

builddir := $(localstatedir)/tmp/$(name)/build
dbdir := $(localstatedir)/db/$(name)

BINS := $(patsubst %.in, %, $(wildcard bin/*.in))
LIBS := $(patsubst %.in, %, $(wildcard lib/*.in))
MANS := $(patsubst %.adoc, %, $(wildcard man/*.adoc))
HTMLS := $(patsubst %.adoc, %.html, $(wildcard man/*.adoc))

INSTALLS := \
	$(addprefix $(DESTDIR)$(bindir)/,$(BINS:bin/%=%)) \
	$(addprefix $(DESTDIR)$(libdir)/,$(LIBS:lib/%=%)) \
	$(dbdir)/ \
	$(builddir)/

.PHONY: all
all: bin lib man html

.PHONY: clean
clean:
	rm -f $(BINS) $(LIBS) $(MANS) $(HTMLS)

.PHONY: install
install: $(INSTALLS)

.PHONY: bin
bin: $(BINS)

.PHONY: lib
lib: $(LIBS)

.PHONY: man
man: $(MANS)

.PHONY: html
html: $(HTMLS)

bin/%: bin/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$(libdir)|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@dbdir@@|$(dbdir)|g" \
		-e "s|@@builddir@@|$(builddir)|g" \
		$< > $@
	chmod +x $@

lib/%: lib/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$(libdir)|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@dbdir@@|$(dbdir)|g" \
		-e "s|@@builddir@@|$(builddir)|g" \
		$< > $@

.DELETE_ON_ERROR: man/%
man/%.html: man/%.adoc
	asciidoctor --failure-level=WARNING -b html5 -B $(PWD) -o $@ $<

.DELETE_ON_ERROR: man/%
man/%: man/%.adoc
	asciidoctor --failure-level=WARNING -b manpage -B $(PWD) -d manpage -o $@ $<

$(DESTDIR)$(bindir)/%: bin/%
	install -D $< $@

$(DESTDIR)$(libdir)/%: lib/%
	install -D -m 0644 $< $@

$(DESTDIR)$(dbdir)/:
$(DESTDIR)$(builddir)/:
	mkdir -p $@
