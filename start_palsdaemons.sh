#!/bin/bash

me=$(whoami)

if [ ! -z "$PBS_JOBID" ] ; then
    SCRATCH=/glade/scratch/${me}/.palsd/${PBS_JOBID}/var/tmp/$(hostname -s)
    if [ ! -d ${SCRATCH} ] ; then
        mkdir -p ${SCRATCH}
    fi
    SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    if [ $(hostname -s| awk '$1 ~ /^r/') ] ; then
        suff=""
    else
        suff="-ib"
    fi
    for host in $(cat ${PBS_NODEFILE}|uniq)
    do
        shorth=$(echo $host|awk -F. '{print $1}')
        shorthip=$(getent hosts "${shorth}${suff}"|awk '{print $1}')
        ssh -o LogLevel=ERROR ${shorthip} env PBS_JOBID=$PBS_JOBID \
                                          SINGULARITY=${SINGULARITY} \
                                          SCR_IMAGEROOT=${SCR_IMAGEROOT} \
                                          DEB_SCRATCH=${DEB_SCRATCH} \
                                          STARTUPENV=${STARTUPENV} \
                    ${SCRDIR}/start_palsd.sh
    done
fi
