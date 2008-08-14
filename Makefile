# 
#  Copyright IBM Corporation. 2007
# 
#  Authors:	Balbir Singh <balbir@linux.vnet.ibm.com>
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of version 2.1 of the GNU Lesser General Public License
#  as published by the Free Software Foundation.
# 
#  This program is distributed in the hope that it would be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
YACC_DEBUG=-t
DEBUG=-DDEBUG
INC=-I.
LIBS= -lcgroup -lpthread
LDFLAGS= -L .
YACC=byacc
LEX=flex
bindir=${exec_prefix}/bin
sbindir=${exec_prefix}/sbin
libdir=${exec_prefix}/lib
includedir=${prefix}/include
prefix=/usr
exec_prefix=${prefix}
INSTALL=install
INSTALL_DATA=install -m 644
PACKAGE_VERSION=0.2
CFLAGS=-g -O2 $(INC) -DPACKAGE_VERSION=$(PACKAGE_VERSION)
VERSION=1

all: libcgroup.so cgconfigparser

cgconfigparser: libcgroup.so config.c y.tab.c lex.yy.c libcgroup.h file-ops.c
	$(CC) $(CFLAGS) -o $@ y.tab.c lex.yy.c config.c file-ops.c \
	$(LDFLAGS) $(LIBS)

y.tab.c: parse.y lex.yy.c
	$(YACC) -v -d parse.y

lex.yy.c: lex.l
	$(LEX) lex.l

libcgroup.so: api.c libcgroup.h wrapper.c
	$(CC) $(CFLAGS) -shared -fPIC -Wl,--soname,$@.$(VERSION) -o $@ api.c \
	wrapper.c
	ln -sf $@ $@.$(VERSION)

test:
	$(MAKE) -C tests

install: libcgroup.so
	$(INSTALL_DATA) -D libcgroup.h $(DESTDIR)$(includedir)/libcgroup.h
	$(INSTALL) -D libcgroup.so $(DESTDIR)$(libdir)/libcgroup-$(PACKAGE_VERSION).so
	ln -sf libcgroup-$(PACKAGE_VERSION).so $(DESTDIR)$(libdir)/libcgroup.so.$(VERSION)
	ln -sf libcgroup.so.$(VERSION) $(DESTDIR)$(libdir)/libcgroup.so
	$(INSTALL) -D cgconfigparser $(DESTDIR)$(sbindir)

uninstall: libcgroup.so
	rm -f $(DESTDIR)$(includedir)/libcgroup.h
	rm -f $(DESTDIR)$(libdir)/libcgroup.so
	rm -f $(DESTDIR)$(libdir)/libcgroup.so.$(VERSION)
	rm -f $(DESTDIR)$(libdir)/libcgroup-$(PACKAGE_VERSION).so
	rm -f $(DESTDIR)$(sbindir)/cgconfigparser

clean:
	\rm -f y.tab.c y.tab.h lex.yy.c y.output cgconfig libcgroup.so \
	libcgroup.so.$(VERSION) cgconfigparser config.log config.status
	$(MAKE) -C tests clean
