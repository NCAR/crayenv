
if [ ! -z "${PBS_JOBID}" -a -z "${SLURM_PREF}" ] ; then
   me=$(whoami)
   slurmroot="/glade/u/apps/ch/opt/hpe-cpe/1.4.1/slurm/21.08.0"
   slurmbin=${slurmroot}/bin
   slurmsbin=${slurmroot}/sbin
   export SLURM_PREF="/glade/scratch/${me}/.slurm/${PBS_JOBID}"
   export SLURM_CONF="${SLURM_PREF}/etc/slurm.conf"
   export SLURM_PREF SLURM_CONF
   export SLURM_PATH=${slurmbin}:${slurmsbin}
   export PATH=${SLURM_PATH}:$PATH
fi
