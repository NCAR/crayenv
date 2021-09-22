#!/bin/bash

me=$(whoami)
wd=$(pwd)
CCPREF=/glade/u/apps/ch/opt/charliecloud/2020-10-21/bin
IMAGEROOT=/glade/u/apps/ch/opt/hpe-cpe/1.4.1/1.4.1.sb
source /etc/profile.d/modules.sh
ml purge
unset MODULEPATH_ROOT
unset MODULEPATH
unset MODULESHOME
unset -f module
unset -f ml

if [ ! -z "$PBS_JOBID" ] ; then
    SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    slurmdpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmd"{print $1}')
    if [ -z "${slurmdpid}" ] ; then
       $CCPREF/ch-run -b/glade:/glade -b/tmp:/tmp --cd=${wd} \
         --set-env=${IMAGEROOT}/ch/environment ${IMAGEROOT} -- ${SCRDIR}/slurmd.sh $PBS_JOBID
    fi
fi
