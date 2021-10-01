#!/bin/bash

SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

me=$(whoami)
source ${SCRDIR}/slurmenv.bash
spooldir="/slurm/d"
stateloc="${SLURM_PREF}/var/spool/slurm/ctld"
logdir="${SLURM_PREF}/var/log/"
confdir=$( dirname ${SLURM_CONF} )
keydir="${SLURM_PREF}/keys"


crdir()
{
   if [ ! -d $1 ] ; then
      mkdir -p $1
   fi
}

crdir ${confdir}
crdir ${spooldir}
crdir ${stateloc}
crdir ${logdir}
crdir ${keydir}

headnode=$(hostname -s)
if [ $(echo $headnode| awk '$1 ~ /^r/') ] ; then
    suff=""
else
    suff="-ib"
fi
headnodeip=$(getent hosts "${headnode}${suff}"|awk '{print $1}')
taskspnode=$(awk '{a[$0]++}END{for (key in a){print a[key]}}' ${PBS_NODEFILE}|head -1)
if [ -z "${SLURM_THREADS_PER_CORE}" ] ; then
   TPC=1
else
   TPC=${SLURM_THREADS_PER_CORE}
fi

prvkey=${keydir}/private.key
pubkey=${keydir}/public.key
openssl genrsa -out ${prvkey} 1024 2> /dev/null
openssl rsa -in ${prvkey} -pubout -out ${pubkey} 2> /dev/null
chmod 600 ${prvkey}

slurmctldport=$(( 8192 + $(echo $PBS_JOBID|awk -F\. '{print $1}'|cut -c -4) ))
slurmdport=$(( $slurmctldport + 1 ))

cat << EOF > ${SLURM_CONF}
JobCredentialPrivateKey=${prvkey}
JobCredentialPublicCertificate=${pubkey}
AuthType=auth/none
CryptoType=crypto/none
ProctrackType=proctrack/pgid
ReturnToService=1
SlurmctldPidFile=/slurmctld.pid
SlurmctldPort=${slurmctldport}
SlurmdPidFile=/tmp/slurmd.pid
SlurmdPort=${slurmdport}
SlurmdSpoolDir=${spooldir}
SlurmUser=${me}
SlurmdUser=${me}
StateSaveLocation=${stateloc}
SwitchType=switch/none
TaskPlugin=task/none
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
SchedulerType=sched/backfill
SelectType=select/linear
AccountingStorageType=accounting_storage/none
AccountingStoreFlags=job_comment
ClusterName=cluster
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=3
SlurmdDebug=3
MpiDefault=cray_shasta
ControlMachine=${headnode}
ControlAddr=${headnodeip}
PartitionName=regular Nodes=ALL Default=YES MaxTime=INFINITE State=UP
NodeName=DEFAULT Sockets=1 CoresPerSocket=${taskspnode} ThreadsPerCore=${TPC} State=UNKNOWN
EOF

for host in $(cat ${PBS_NODEFILE}|sort -u)
do
   shorth=$(echo $host|awk -F. '{print $1}')
   shorthip=$(getent hosts "${shorth}${suff}"|awk '{print $1}')
   printf "NodeName=%s NodeAddr=%s\n" ${shorth} ${shorthip} >> $SLURM_CONF
done
