#!/bin/bash

export PALSD_LOGFILE PALSD_DEBUG PALSD_RUN_DIR PALSD_PORT PALS_PORT RFE_811452_DISABLE
#export PALSD_LOGFILE PALSD_DEBUG PALSD_RUN_DIR RFE_811452_DISABLE

me=$(whoami)

if [ ! -z "$JUST_JOBID" ] ; then
    palsdpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "palsd"{print $1}')
    if [ -z "${palsdpid}" ] ; then
       DEB_SCRATCH=/glade/scratch/${me}/.palsd/${JUST_JOBID}/var/$(hostname -s)
       PALSETC=/glade/scratch/${me}/.palsd/${JUST_JOBID}/etc
       if [ ! -d ${DEB_SCRATCH} ] ; then
           mkdir -p ${DEB_SCRATCH}
       fi
       if [ ! -d ${PALSETC} ] ; then
           mkdir -p ${PALSETC}
       fi
       LOC_BINDARGS="${BINDARGS},${DEB_SCRATCH}:/tmp,${DEB_SCRATCH}:/var/run/palsd,${PALSETC}:/etc/pals"
       echo "Starting palsd in node $(hostname -s)... "
       SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
       source /etc/profile.d/modules.sh
       ml purge
       unset MODULEPATH_ROOT
       unset MODULEPATH
       unset MODULESHOME
       unset -f module
       unset -f ml
       nohup ${SINGULARITY} run -u ${LOC_BINDARGS} \
           --env-file ${STARTUPENV} ${SCR_IMAGEROOT} /bin/bash -c ${SCRDIR}/palsd.sh > /dev/null 2>&1 < /dev/null &
    fi
fi
