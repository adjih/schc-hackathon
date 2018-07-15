#---------------------------------------------------------------------------

#GITURL_PYCOM_MICROPYTHON?=https://gitlab.inria.fr/adjih/pycom-micropython -b module-libschic
#BOARD?=LOPY4

GITURL_MICROPYTHON?=https://github.com/micropython/micropython
M=micropython

#---------------------------------------------------------------------------

all: repos

#---------------------------------------------------------------------------

repos: schc-test schc-test-cedric ${M}

schc-test:
	git clone --recursive https://github.com/dbarthel-ol/schc-test

schc-test-cedric:
	git clone --recursive https://github.com/adjih/schc-test \
               -b cedric-hackathon102 schc-test-cedric

${M}:
	git clone ${GITURL_MICROPYTHON}
	cd ${M} && git submodule update --init

#---------------------------------------------------------------------------

native-build:
	make ${M}
	cd ${M}/ports/unix && make axtls
	cd ${M}/ports/unix && make V=1

send: native-build
	${M}/ports/unix/micropython test_schc.py send

recv: native-build
	${M}/ports/unix/micropython test_schc.py recv


run-upy:
	${M}/ports/unix/micropython

#---------------------------------------------------------------------------
