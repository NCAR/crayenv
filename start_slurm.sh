#!/bin/bash

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
    source ${SCRDIR}/slurmenv.bash
    if [ ! -d $SLURM_PREF ] ; then
       ${SCRDIR}/crconf.sh
    fi
    slurmctldpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmctld"{print $1}')
    if [ -z "${slurmctldpid}" ] ; then
       $CCPREF/ch-run -b/glade:/glade -b/tmp:/tmp --cd=${wd} \
         --set-env=${IMAGEROOT}/ch/environment ${IMAGEROOT} -- ${SCRDIR}/slurmctld.sh
    fi
    headnode=$(hostname -s)
    if [ $(echo $headnode| awk '$1 ~ /^r/') ] ; then
        suff=""
    else
        suff="-ib"
    fi
    for host in $(cat ${PBS_NODEFILE}|uniq)
    do
        shorth=$(echo $host|awk -F. '{print $1}')
        shorthip=$(getent hosts "${shorth}${suff}"|awk '{print $1}')
        ssh ${shorthip} PBS_JOBID=$PBS_JOBID ${SCRDIR}/start_slurmd.sh
    done
#   slurmdpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmd"{print $1}')
#   if [ -z "${slurmdpid}" ] ; then
#      $CCPREF/ch-run -b/glade:/glade -b/tmp:/tmp --cd=${wd} \
#        --set-env=${IMAGEROOT}/ch/environment ${IMAGEROOT} -- ${SCRDIR}/slurmd.sh
#   fi
fi
