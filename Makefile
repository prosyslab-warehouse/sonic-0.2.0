# This file was written by Bill Cox in 2010, and is licensed under the Apache
# 2.0 license.
#
# Note that -pthread is only included so that older Linux builds will be thread
# safe.  We call malloc, and older Linux versions only linked in the thread-safe
# malloc if -pthread is specified.

SONAME=soname
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  SONAME=install_name
endif
#CFLAGS=-Wall -g -ansi -fPIC -pthread
CFLAGS ?= -Wall -O3
CFLAGS += -ansi -fPIC -pthread
LIB_TAG=0.2.0
CC=gcc
PREFIX=/usr
LIBDIR=$(PREFIX)/lib

all: sonic libsonic.so.$(LIB_TAG) libsonic.a

sonic: wave.o main.o libsonic.so.$(LIB_TAG)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o sonic wave.o main.o libsonic.so.$(LIB_TAG)

sonic.o: sonic.c sonic.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c sonic.c

wave.o: wave.c wave.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c wave.c

main.o: main.c sonic.h wave.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c main.c

libsonic.so.$(LIB_TAG): sonic.o
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -Wl,-$(SONAME),libsonic.so.0 sonic.o -o libsonic.so.$(LIB_TAG)
	ln -sf libsonic.so.$(LIB_TAG) libsonic.so
	ln -sf libsonic.so.$(LIB_TAG) libsonic.so.0

libsonic.a: sonic.o
	$(AR) cqs libsonic.a sonic.o

install: sonic libsonic.so.$(LIB_TAG) sonic.h
	install -d $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(PREFIX)/include $(DESTDIR)$(LIBDIR)
	install sonic $(DESTDIR)$(PREFIX)/bin
	install sonic.h $(DESTDIR)$(PREFIX)/include
	install libsonic.so.$(LIB_TAG) $(DESTDIR)$(LIBDIR)
	install libsonic.a $(DESTDIR)$(LIBDIR)
	ln -sf libsonic.so.$(LIB_TAG) $(DESTDIR)$(LIBDIR)/libsonic.so
	ln -sf libsonic.so.$(LIB_TAG) $(DESTDIR)$(LIBDIR)/libsonic.so.0

uninstall: 
	rm -f $(DESTDIR)$(PREFIX)/bin/sonic 
	rm -f $(DESTDIR)$(PREFIX)/include/sonic.h
	rm -f $(DESTDIR)$(LIBDIR)/libsonic.so.$(LIB_TAG)
	rm -f $(DESTDIR)$(LIBDIR)/libsonic.so
	rm -f $(DESTDIR)$(LIBDIR)/libsonic.so.0
	rm -f $(DESTDIR)$(LIBDIR)/libsonic.a

clean:
	rm -f *.o sonic libsonic.so* libsonic.a
