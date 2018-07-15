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

send:
	test -e ${M}/ports/unix/micropython || make native-build
	${M}/ports/unix/micropython test_schc.py send

recv:
	test -e ${M}/ports/unix/micropython || make native-build
	${M}/ports/unix/micropython test_schc.py recv


run-upy:
	${M}/ports/unix/micropython

#---------------------------------------------------------------------------

# S=schc-test-cedric
# SCHC_SOURCES = $(wildcard ${S}/schc*.py) \
#                $(wildcard ${S}/micro_enum/[a-z]*.py) \
#                $(wildcard ${S}/pybinutil/[a-z]*.py) \
#                ${S}/debug_print.py
# PYFILELIST=test_schc.py

# LINKDIR=project/link

# link:
# 	test -e ${LINKDIR} || mkdir ${LINKDIR}
# 	for i in ${SCHC_SOURCES} ${PYFILELIST} ; do \
#               (cd ${LINKDIR} && ln -vsf ../../$$i .) ; \
#         done

#---------------------------------------------------------------------------

DEVICE1 ?= /dev/ttyACM0
DEVICE2 ?= /dev/ttyACM1
-include Makefile.local # override DEVICE1, DEVICE2 here

link:
	./gen-link-dir.sh sending ${DEVICE1} main-sending.py
	./gen-link-dir.sh receiving ${DEVICE2} main-receiving.py

#---------------------------------------------------------------------------
