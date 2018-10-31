#---------------------------------------------------------------------------
# Cedric Adjih - 2018
#---------------------------------------------------------------------------

# Optionally put information in this file to override options
-include Makefile.local

GITPLACE=openschc

GITURL_MICROPYTHON?=https://github.com/${GITPLACE}/micropython
GITBRANCH_MICROPYTHON?=hackathon-103
M=micropython

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

all: repos

repos: ${M}

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
#---------------------------------------------------------------------------

# Mac-OS, before make native-build (XXX: problem, as libffi is cloned?)
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

send: native-build
	${M}/ports/unix/micropython test_schc.py send

recv: native-build
	${M}/ports/unix/micropython test_schc.py recv

send_recv: native-build
	${M}/ports/unix/micropython test_schc.py send_recv

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

#GITURL_PYCOM_MICROPYTHON?=https://gitlab.inria.fr/adjih/pycom-micropython -b module-libschic
#BOARD?=LOPY4

#---------------------------------------------------------------------------

DEVICE1_TTY ?= /dev/ttyACM0
DEVICE2_TTY ?= /dev/ttyACM1
-include Makefile.local # override DEVICE1_TTY, DEVICE2_TTY here

link:
	./gen-link-dir.sh sending ${DEVICE1_TTY} main-sending.py
	./gen-link-dir.sh receiving ${DEVICE2_TYY} main-receiving.py

#---------------------------------------------------------------------------

link-send: native-build
	cd project-sending && ../${M}/ports/unix/micropython test_schc.py send

link-recv: native-build
	cd project-receiving && ../${M}/ports/unix/micropython test_schc.py recv

#---------------------------------------------------------------------------

cpy-send: ; python3 test_schc.py send

cpy-recv: ; python3 test_schc.py recv

#---------------------------------------------------------------------------
