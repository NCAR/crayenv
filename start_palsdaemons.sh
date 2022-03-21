#!/bin/bash


me=$(whoami)
export HOST

if [ ! -z "$JUST_JOBID" ] ; then
    SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    if [ $(hostname -s| awk '$1 ~ /^r/') ] ; then
        suff=""
    else
        suff="-ib"
    fi
    hostlist=""
    for host in $(cat ${PBS_NODEFILE}|uniq)
    do
        shorth=$(echo $host|awk -F. '{print $1}')
        hostlist="${hostlist} ${shorth}"
    done
    H=1
    for shorth in ${hostlist}
    do
        shorthip=$(getent hosts "${shorth}${suff}"|awk '{print $1}')
        if [ $H -eq 1 ] ; then
            ssh -o LogLevel=ERROR ${shorthip} env JUST_JOBID=$JUST_JOBID \
                                          SINGULARITY=${SINGULARITY} \
                                          SCR_IMAGEROOT=${SCR_IMAGEROOT} \
                                          BINDARGS=${BINDARGS} \
                                          GPUARGS="${GPUARGS}" \
                                          STARTUPENV=${STARTUPENV} \
                                          PALSD_LOGFILE=${PALSD_LOGFILE} \
                                          PALSD_DEBUG=${PALSD_DEBUG} \
                                          PALSD_RUN_DIR=${PALSD_RUN_DIR} \
                                          PALSD_PORT=${PALSD_PORT} \
                                          PALS_PORT=${PALS_PORT} \
                                          RFE_811452_DISABLE=${RFE_811452_DISABLE} \
                    ${SCRDIR}/create_pals_keys.sh
            H=0
        fi
        ssh -o LogLevel=ERROR ${shorthip} env JUST_JOBID=$JUST_JOBID \
                                          SINGULARITY=${SINGULARITY} \
                                          SCR_IMAGEROOT=${SCR_IMAGEROOT} \
                                          BINDARGS=${BINDARGS} \
                                          GPUARGS="${GPUARGS}" \
                                          STARTUPENV=${STARTUPENV} \
                                          PALSD_LOGFILE=${PALSD_LOGFILE} \
                                          PALSD_DEBUG=${PALSD_DEBUG} \
                                          PALSD_RUN_DIR=${PALSD_RUN_DIR} \
                                          RFE_811452_DISABLE=${RFE_811452_DISABLE} \
                                          PALSD_PORT=${PALSD_PORT} \
                                          PALS_PORT=${PALS_PORT} \
                    ${SCRDIR}/start_palsd.sh
    done
fi
