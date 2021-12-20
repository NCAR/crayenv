#!/bin/bash

me=$(whoami)

if [ ! -z "$PBS_JOBID" ] ; then
    SCRATCH=/glade/scratch/${me}/.slurm/${PBS_JOBID}/var/tmp/$(hostname -s)
    if [ ! -d ${SCRATCH} ] ; then
        mkdir -p ${SCRATCH}/d
    fi
    SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    source ${SCRDIR}/slurmenv.bash
    if [ ! -d "$SLURM_PREF/etc" ] ; then
       echo "Setting up Slurm configuration.."
       ${SCRDIR}/crconf.sh
    else
       echo "Found Slurm configuration.."
    fi
    slurmctldpid=$(ps -u ${me} -o pid,comm=|awk '$2 == "slurmctld"{print $1}')
    if [ -z "${slurmctldpid}" ] ; then
       rm -f ${SCRATCH}/*.pid ${SCRATCH}/d/*
       echo "Starting slurmctld ..."
       source /etc/profile.d/modules.sh
       ml purge
       unset MODULEPATH_ROOT
       unset MODULEPATH
       unset MODULESHOME
       unset -f module
       unset -f ml
       ${SINGULARITY} run -u -B/glade,${SCRATCH}:/tmp --env-file ${STARTUPENV} \
              ${SCR_IMAGEROOT} /bin/bash -c ${SCRDIR}/slurmctld.sh
    else
       echo "found slurmctld running.."
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
        ssh -o LogLevel=ERROR ${shorthip} env PBS_JOBID=$PBS_JOBID \
                                          SINGULARITY=${SINGULARITY} \
                                          SCR_IMAGEROOT=${SCR_IMAGEROOT} \
                                          STARTUPENV=${STARTUPENV} \
                    ${SCRDIR}/start_slurmd.sh
    done
fi
