#! /bin/sh
#
# puppet: ./modules/grid/files/root/srv-check-atlas-squid.sh
#
#         (Attention: changes will be overwritten by puppet)
#

# do NOT run this script on puppetfirstrun
test "$(/opt/puppetlabs/bin/facter puppetfirstrun)" == "true" && exit

# only proceed if this machine is running in production
test "$(/opt/puppetlabs/bin/facter is_production)" == "true" || exit

MAIL="grid-ops@desy.de"

HOST=$(/bin/hostname -s)
DATE=$(/bin/date +%Y%m%d-%H%M%S)

echo
echo "[${DATE}] ----- BEGIN -----"

/sbin/service frontier-squid status
rc=$?
if [ $rc -ne 0 ]; then

    strg="[${DATE}] SQUID ERROR ${HOST}: Restarting ..."
    echo "${strg}"
    echo "${strg}" | mail -s "[${HOST}] SQUID error [${DATE}]: Restarting ..." ${MAIL}

    /sbin/service frontier-squid stop

    sleep 10

    /sbin/service frontier-squid start

fi

echo "[$(/bin/date +%Y%m%d-%H%M%S)] ----- END -----"
