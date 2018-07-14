#---------------------------------------------------------------------------

#GITURL_PYCOM_MICROPYTHON?=https://gitlab.inria.fr/adjih/pycom-micropython -b module-libschic
#BOARD?=LOPY4

GITURL_MICROPYTHON?=https://github.com/micropython/micropython
M=micropython

#---------------------------------------------------------------------------

all: repos

#---------------------------------------------------------------------------

repos: schc-test ${M}

schc-test:
	git clone --recursive https://github.com/dbarthel-ol/schc-test

${M}:
	git clone ${GITURL_MICROPYTHON}
	cd ${M} && git submodule update --init

#---------------------------------------------------------------------------

native-build:
	make ${M}
	cd ${M}/ports/unix && make axtls
	cd ${M}/ports/unix && make V=1

run:
	make native-build
	cd ${M}/ports/unix && ./micropython ../../../test_schc.py

#---------------------------------------------------------------------------
