#!/bin/bash 
SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRDIR}/slurmenv.bash
logdir="${SLURM_PREF}/var/log/"
slurmctld -L ${logdir}/slurmctld.$(hostname -s).log
