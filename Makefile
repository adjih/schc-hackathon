#---------------------------------------------------------------------------
# Cedric Adjih - 2018
#---------------------------------------------------------------------------

# Optionally put information in this file to override options
-include Makefile.local

GITPLACE?=PLEASE-SET-VARIABLE-GITPLACE
GITPLACE_UPY?=openschc

GITURL_MICROPYTHON?=https://github.com/${GITPLACE_UPY}/micropython
GITURL_MICROPYTHON_LIB?=https://github.com/${GITPLACE_UPY}/micropython-lib
GITBRANCH_MICROPYTHON?=hackathon103
GITBRANCH_MICROPYTHON_LIB?=hackathon103
M=micropython
MLIB=micropython-lib

GITURL_OPENSCHC?=https://github.com/${GITPLACE}/openschc
GITBRANCH_OPENSCHC?=hackathon103
GITURL_OPENSCHC_OFFICIAL=https://github.com/openschc

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

all: repos

repos: ${M} ${MLIB} openschc

#---------------------------------------------------------------------------
# Micropython

${M}:
	git clone ${GITURL_MICROPYTHON} -b ${GITBRANCH_MICROPYTHON}
	cd ${M} && git submodule update --init

${MLIB}:
	git clone ${GITURL_MICROPYTHON_LIB} -b ${GITBRANCH_MICROPYTHON_LIB}

native-build:
	make ${M}
	cd ${M}/ports/unix && make axtls
	cd ${M}/ports/unix && make V=1

test-upy:
	test -e ${M}/ports/unix/micropython || make native-build
	${M}/ports/unix/micropython test_upy.py

test-oschc:
	test -e ${M}/ports/unix/micropython || make native-build
	cd openschc/src && ../../${M}/ports/unix/micropython test_oschc.py

test-schc-test-send:
	test -e ${M}/ports/unix/micropython || make native-build
	${M}/ports/unix/micropython old/test_schc.py send

test-schc-test-recv:
	test -e ${M}/ports/unix/micropython || make native-build
	${M}/ports/unix/micropython old/test_schc.py recv

run-upy:
	${M}/ports/unix/micropython

#---------------------------------------------------------------------------
# openschc

openschc:
	git clone ${GITURL_OPENSCHC} -b ${GITBRANCH_OPENSCHC}

ensure-remote-osc:
	git remote | grep -q '^osc$$' \
           || git remote add osc ${GITURL_OPENSCHC_OFFICIAL}/schc-hackathon
	cd openschc && { \
	   git remote | grep -q '^osc$$' \
              || git remote add osc ${GITURL_OPENSCHC_OFFICIAL}/openschc ; }

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

# Note: Mac-OS, before make native-build (XXX: problem, as libffi is cloned?)
# export PKG_CONFIG_PATH=/usr/local/Cellar/libffi/3.2.1/lib/pkgconfig
#---------------------------------------------------------------------------
