#!/bin/bash

printf "\n\n"
echo "*** THIS MUST BE BUILT WITHIN CONTAINER ***"
echo "*** Am I running in container (y/n) ?   ***"
printf "\n\n"
read -n 1 r
if [ "$r" != "y" ] ; then
   echo "... exiting..."
fi
exit

VERS="21.08.0"
SPREF=/glade/u/apps/ch/opt/hpe-cpe/1.4.1/slurm/
PREF=${SPREF}/${VERS}/
BDIR="slurm-"${VERS}
TARBALL=${BDIR}.tar.bz2

wget https://download.schedmd.com/slurm/${TARBALL}
tar xf ${TARBALL}
cd ${BDIR}
./configure --prefix=${PREF}
make
make install
