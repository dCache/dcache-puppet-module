#!/bin/sh

################################
# This script takes dumps of files in the ATLAS space tokens known to chimera
# and uploads them to the dumps/ dubdirectories in the roots of the space tokens
# it is intended for the user grid on t2-atlas-squid02.desy.de
# it requires a valid proxy, that is requested at start 
# thus a passwordless certificate is expected in /home/grid/.globus
#
# the script is at /home/grid/bin/atlas_space_dumps.sh calling /home/grid/bin/chimera_find.sh
#
# dumps are kept locally in /data/spacetoken_dumps/
# the dumps are rotated monthly by /etc/logrotate.d/spacetoken_dumps
# (including prerotate-tuning to tar all dumps_YYYYMMMDD into a dump.tar under logrotate control)
#
# v20160127 thomas.hartmann@desy.de
#


/cvmfs/grid.cern.ch/centos7-ui-v03/usr/bin/voms-proxy-init -voms desy

DAYSAGO=3
#DUMPDATE=$(/bin/echo "`date  +"%Y%m%d"` - $DAYSAGO" | bc)
DUMPDATE=`/bin/date --date="3 days ago"  +"%Y%m%d"`

for SPACETOKEN in atlasscratchdisk atlasdatadisk;
#for SPACETOKEN in atlasdatadisk atlaslocalgroupdisk;
do
    DUMPSRM="gsiftp://dcache-door-atlas14.desy.de:2811/pnfs/desy.de/atlas/dq2/${SPACETOKEN}/dumps"
    DUMPPATH="/data/spacetoken_dumps/${SPACETOKEN}/dump"
    DUMPDATEPATH="${DUMPPATH}_${DUMPDATE}"
    DUMPLOG="${DUMPDATEPATH}.log"

    /bin/echo ${DUMPLOG}
    /bin/echo "SRM path ${DUMPSRM}"  >> $DUMPLOG
    /bin/echo "dump path ${DUMPPATH}"  >> $DUMPLOG
    /bin/echo "date ${DUMPDATEPATH}" >> $DUMPLOG
    /bin/echo "log path ${DUMPLOG}" >> $DUMPLOG

    /bin/date >> $DUMPLOG
    # deleting previous dumps # testing - not hot yet
    for FILEINDUMP in `gfal-ls $DUMPSRM`; do
	/bin/echo -e "\n would going to delete $DUMPSRM/$FILEINDUMP:" >> $DUMPLOG
	/bin/echo "/cvmfs/grid.cern.ch/centos7-ui-v03/usr/bin/gfal-rm $DUMPSRM/$FILEINDUMP" >> $DUMPLOG
    done


    chimeraCMD="/usr/local/bin/chimera_find.sh -h dcache-dir-atlas -p 5432 -U atlasmon -s -D \"$DAYSAGO days ago\" ${DUMPPATH} /pnfs/desy.de/atlas/dq2/${SPACETOKEN}/rucio/ &>>  $DUMPLOG"
    /bin/echo -e "$chimeraCMD" >> $DUMPLOG
#    eval $chimeraCMD
    /bin/echo -e "taking dump done\npreparing dump for ATLAS" >> $DUMPLOG
    /bin/cut -d "/" -f 7- ${DUMPPATH} | cut -d "|" -f 1 >> "${DUMPDATEPATH}"
    /bin/echo "copying dump to space token" >> "${DUMPLOG}"
    gfalCMD="/cvmfs/grid.cern.ch/centos7-ui-v03/usr/bin/gfal-copy -f file://${DUMPDATEPATH} gsiftp://dcache-door-atlas14.desy.de:2811/pnfs/desy.de/atlas/dq2/$SPACETOKEN/dumps/"
    /bin/echo -e "$gfalCMD" >> $DUMPLOG
    eval $gfalCMD
done
