# In the good tradition of Autconf...

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
datarootdir = ${prefix}/share
mandir = ${datarootdir}/man

INSTALL = /usr/bin/install -c

INSTALL_DATA = $(INSTALL) -m 644
INSTALL_SCRIPT = $(INSTALL)

TAR = /usr/bin/tar

PACKAGE = openstdin
VERSION = 0.1

distdir = $(PACKAGE)-$(VERSION)
top_distdir = $(distdir)

#

dist_bin_SCRIPTS = openstdin mime
dist_MAN1_MANS = openstdin.1

FILES = $(dist_bin_SCRIPTS) $(dist_MAN1_MANS)
DISTFILES = Makefile $(FILES) $(EXTRA_DIST)

#

all: $(FILES)

install: all
	for f in $(dist_bin_SCRIPTS); do \
	    $(INSTALL_SCRIPT) $$f $(DESTDIR)$(bindir) || exit 1; \
        done
	for f in $(dist_MAN1_MANS); do \
	    $(INSTALL_DATA) $$f $(DESTDIR)$(mandir)/man1 || exit 1; \
	done

install-strip: install

distdir: $(DISTFILES)
	$(RM) -r "$(distdir)"
	test -d "$(distdir)" || mkdir "$(distdir)"
	for file in $(DISTFILES); do \
	    cp -fpR $$file "$(distdir)" || exit 1; \
	done

dist-gzip: distdir
	$(TAR) cf - $(distdir) | GZIP=$(GZIP_ENV) gzip -c >$(distdir).tar.gz
	$(RM) -r "$(distdir)"

dist-bzip2: distdir
	$(TAR) cf - $(distdir) | bzip2 -9 -c >$(distdir).tar.bz2
	$(RM) -r "$(distdir)"

dist dist-all: dist-gzip

.PHONY: check
check:

.PHONY: clean maintainer-clean
clean maintainer-clean:

distclean: clean
	-$(RM) $(distdir).tar.gz $(distdir).tar.bz2
