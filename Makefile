OUT        = xrectsel

SRC        = ${wildcard *.c}
OBJ        = ${SRC:.c=.o}
DISTFILES  = Makefile README.md ffcast.1.pod ffcast.sh xrectsel.c

PREFIX    ?= /usr
MANPREFIX ?= ${PREFIX}/share/man

CFLAGS    := --std=c99 -g -pedantic -Wall -Wextra -Wno-variadic-macros ${CFLAGS}
LDFLAGS   := -lX11 ${LDFLAGS}

all: ${OUT} doc

${OUT}: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

doc: ffcast.1

ffcast.1: ffcast.1.pod
	pod2man --center="FFcast Manual" --name="FFCAST" --release="ffcast" --section=1 $< > $@

strip: ${OUT}
	strip --strip-all ${OUT}

install: ffcast.1 ffcast.sh xrectsel
	install -D -m755 xrectsel ${DESTDIR}${PREFIX}/bin/xrectsel
	install -D -m755 ffcast.sh ${DESTDIR}${PREFIX}/bin/ffcast
	install -D -m755 ffcast.1 ${DESTDIR}${MANPREFIX}/man1/ffcast.1

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	rm -f ${DESTDIR}${PREFIX}/bin/xrectsel
	rm -f ${DESTDIR}${PREFIX}/bin/ffcast
	@echo removing man page from ${DESTDIR}${MANPREFIX}/man1/ffcast.1
	rm -f ${DESTDIR}${MANPREFIX}/man1/ffcast.1

clean:
	${RM} ${OUT} ${OBJ} ffcast.1

.PHONY: clean dist doc install uninstall
