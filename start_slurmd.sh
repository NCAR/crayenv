#!/bin/bash

me=$(whoami)

if [ ! -z "$PBS_JOBID" ] ; then
    slurmdpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmd"{print $1}')
    if [ -z "${slurmdpid}" ] ; then
       rm -f ${SCRATCH}/slurmd.pid ${SCRATCH}/d/*
       echo "Starting slurmd in node $(hostname -s)... "
       SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
       source /etc/profile.d/modules.sh
       ml purge
       unset MODULEPATH_ROOT
       unset MODULEPATH
       unset MODULESHOME
       unset -f module
       unset -f ml
       ${SINGULARITY} run -u -B/glade,${SCRATCH}:/tmp --env-file ${STARTUPENV} \
              ${SCR_IMAGEROOT} /bin/bash -c ${SCRDIR}/slurmd.sh
    fi
fi
