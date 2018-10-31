#! /bin/sh
#---------------------------------------------------------------------------
# Generate a directory with lots of link to proper files
# The directory will be a project repository for atom
#---------------------------------------------------------------------------

if [ "$#" != 2 -a "$#" != 3 ] ; then
    printf "Syntax: $0 <dir suffix> <device tty>\n"
    exit 1
fi

DIR=project-$1
DEVICE_TTY=$2

#---------------------------------------------------------------------------

printf "> Creating links in directory '%s'\n" ${DIR}
test -e ${DIR} || mkdir ${DIR}
(cat pymakr.conf-template | sed s+DEVICE_TTY+${DEVICE_TTY}+g ) \
       > ${DIR}/pymakr.conf

#----------------------------------------

if [ z"$3" != z"" ] ; then
    (cd ${DIR} && ln -svf "../$3" main.py) || exit 1
fi

#----------------------------------------

FILELIST="main.py test_schc.py copied_heapq.py copied_pyssched.py"

for i in ${FILELIST} ; do
    (cd ${DIR} && ln -svf ../$i .) || exit 1
done

SCHCTEST_DIR="schc-test-cedric"
(cd ${DIR} && test -e ${SCHCTEST_DIR} || mkdir ${SCHCTEST_DIR}) || exit 1
for i in ${SCHCTEST_DIR}/*.py ; do
    (cd ${DIR}/${SCHCTEST_DIR} && ln -svf ../../$i .) || exit 1
done

SUBDIRS="micro_enum pybinutil"
for i in ${SUBDIRS} ; do
    (cd ${DIR}/${SCHCTEST_DIR} && test -e ${i} || mkdir ${i}) || exit 1
    (cd ${DIR}/${SCHCTEST_DIR}/$i \
       && ln -svf ../../../${SCHCTEST_DIR}/$i/*.py .) || exit 1
done

#---------------------------------------------------------------------------
