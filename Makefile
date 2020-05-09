name = praxis
version = 20200121

prefix ?=
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
localstatedir ?= $(prefix)/var

libdir := $(libdir)/$(name)

builddir := $(localstatedir)/tmp/$(name)/build
dbdir := $(localstatedir)/db/$(name)
cachedir := $(localstatedir)/cache/$(name)

BINS := $(patsubst %.in, %, $(wildcard bin/*.in))
LIBS := $(patsubst %.in, %, $(wildcard lib/*.in))
MANS := $(patsubst %.adoc, %, $(wildcard man/*.adoc))
HTMLS := $(patsubst %.adoc, %.html, $(wildcard man/*.adoc))

INSTALLS := \
	$(addprefix $(DESTDIR)$(bindir)/,$(BINS:bin/%=%)) \
	$(addprefix $(DESTDIR)$(libdir)/,$(LIBS:lib/%=%))

ASCIIDOCTOR ?= asciidoctor
ASCIIDOCTOR += --failure-level=WARNING -B $(PWD)

.PHONY: all
all: bin lib man html

.PHONY: clean
clean:
	rm -f $(BINS) $(LIBS) $(MANS) $(HTMLS)

.PHONY: install
install: $(INSTALLS)
	mkdir -p $(DESTDIR)$(builddir)
	mkdir -p $(DESTDIR)$(cachedir)
	mkdir -p $(DESTDIR)$(cachedir)/distfiles
	mkdir -p $(DESTDIR)$(dbdir)
	mkdir -p $(DESTDIR)$(dbdir)/repositories

.PHONY: lint
lint:
	printf '%s\n' $(patsubst %,%.in,$(BINS)) $(patsubst %,%.in,$(LIBS)) | xargs shellcheck

.PHONY: test
test: check

.PHONY: check
check: bin lib
	shellspec $(SHELLSPEC_FLAGS)

.PHONY: bin
bin: $(BINS)

.PHONY: lib
lib: $(LIBS)

.PHONY: man
man: $(MANS) README

.PHONY: html
html: $(HTMLS)

bin/%: bin/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$$\{PRAXIS_LIBDIR:-$(libdir)\}|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-$(builddir)\}|g" \
		-e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-$(cachedir)\}|g" \
		-e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-$(dbdir)\}|g" \
		$< > $@.temp
	chmod +x $@.temp
	mv $@.temp $@

lib/%: lib/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$$\{PRAXIS_LIBDIR:-$(libdir)\}|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-$(builddir)\}|g" \
		-e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-$(cachedir)\}|g" \
		-e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-$(dbdir)\}|g" \
		$< > $@.temp
	chmod +x $@.temp
	mv $@.temp $@

.DELETE_ON_ERROR: man/%.html
man/%.html: man/%.adoc
	$(ASCIIDOCTOR) -b html5 -o $@ $<

.DELETE_ON_ERROR: man/%
man/%: man/%.adoc
	$(ASCIIDOCTOR) -b manpage -d manpage -o $@ $<

.DELETE_ON_ERROR: README
README: man/praxis.7
	man $< | col -bx > $@

$(DESTDIR)$(bindir)/%: bin/%
	install -D $< $@

$(DESTDIR)$(libdir)/%: lib/%
	install -D -m 0644 $< $@

