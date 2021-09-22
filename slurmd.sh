#!/bin/bash 
export PBS_JOBID=$1
SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRDIR}/slurmenv.bash
logdir="${SLURM_PREF}/var/log/"
slurmd -L ${logdir}/slurmd.$(hostname -s).log
