
SCRDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH="${SCRDIR}:${PATH}"

CCPREF=/glade/u/apps/ch/opt/charliecloud/2020-10-21/bin
IMAGEROOT=/glade/u/apps/ch/opt/hpe-cpe/1.4.1/1.4.1.sb
CRAYENVSTR="$CCPREF/ch-run -b/glade:/glade -b/tmp:/tmp --cd=\`pwd\` --set-env=${IMAGEROOT}/ch/environment ${IMAGEROOT} -- /bin/bash"
