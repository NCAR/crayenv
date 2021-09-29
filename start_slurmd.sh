#!/bin/bash

me=$(whoami)
wd=$(pwd)
source /etc/profile.d/modules.sh
ml purge
unset MODULEPATH_ROOT
unset MODULEPATH
unset MODULESHOME
unset -f module
unset -f ml

if [ ! -z "$PBS_JOBID" ] ; then
    SCRATCH=/glade/scratch/${me}/.slurm/${PBS_JOBID}/var/tmp/$(hostname -s)
    if [ ! -d ${SCRATCH} ] ; then
        mkdir -p ${SCRATCH}
    fi
    SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    slurmdpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmd"{print $1}')
    if [ -z "${slurmdpid}" ] ; then
       echo "Starting slurmd in node $(hostname -s)... "
       ${SCR_CCPREF}/ch-run -b/glade:/glade -b${SCRATCH}:/tmp --cd=${wd} \
         --set-env=${SCR_IMAGEROOT}/ch/environment ${SCR_IMAGEROOT} -- ${SCRDIR}/slurmd.sh $PBS_JOBID
    fi
fi
