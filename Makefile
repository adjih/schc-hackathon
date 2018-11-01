#---------------------------------------------------------------------------
# Cedric Adjih - 2018
#---------------------------------------------------------------------------

# Optionally put information in this file to override options
-include Makefile.local

GITPLACE?=openschc
GITPLACE_UPY?=openschc

GITURL_MICROPYTHON?=https://github.com/${GITPLACE_UPY}/micropython
GITBRANCH_MICROPYTHON?=hackathon103
M=micropython

GITURL_OPENSCHC?=https://github.com/${GITPLACE}/openschc
GITBRANCH_OPENSCHC?=hackathon103

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

all: repos

repos: ${M} openschc

#---------------------------------------------------------------------------
# Micropython

${M}:
	git clone ${GITURL_MICROPYTHON} -b ${GITBRANCH_MICROPYTHON}
	cd ${M} && git submodule update --init

native-build:
	make ${M}
	cd ${M}/ports/unix && make axtls
	cd ${M}/ports/unix && make V=1

test-upy: native-build
	${M}/ports/unix/micropython test-upy.py

run-upy:
	${M}/ports/unix/micropython

#---------------------------------------------------------------------------
# openschc

openschc:
	git clone ${GITURL_OPENSCHC} -b ${GITBRANCH_OPENSCHC}
	cd ${M} && git submodule update --init

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

# Note: Mac-OS, before make native-build (XXX: problem, as libffi is cloned?)
# export PKG_CONFIG_PATH=/usr/local/Cellar/libffi/3.2.1/lib/pkgconfig

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# Hackathon IETF 102 (Montreal)

repos-102: schc-test schc-test-cedric ${M}

schc-test:
	git clone --recursive https://github.com/dbarthel-ol/schc-test

schc-test-cedric:
	git clone --recursive https://github.com/adjih/schc-test \
               -b cedric-pycom schc-test-cedric

#---------------------------------------------------------------------------
