#!/bin/bash
date
set -x
##############################################
#  wrapper for submitting LL script on ada
##############################################

if [ $# != 4 ] ; then
  echo "USAGE : $(basename $0 ) jpni jpnj jpnij nxios "
  exit 0
fi

if [ ! $PDIR ] ; then
   echo "You must set up your environment for DCM before using the RUN_TOOLS"
   echo PDIR environment variable not set
   exit 1
fi
CONFIG=NACHOS12.L75
CASE=scal
CONFCASE=${CONFIG}-${CASE}

cat  << eof > ${CONFCASE}.db 
1 1 250
eof

jpni=$1
jpnj=$2
jpnij=$3
nxios=$4

ntasks=$(( jpnij + nxios ))
nodes=$(( ntasks / 24 ))
if [ $(( ntasks % 24 )) != 0 ] ; then
  nodes=$(( nodes + 1 ))
fi


cat ./includefile.ksh.tmp | sed -e "s/<JPNI>/$jpni/g" -e "s/<JPNJ>/$jpnj/g" -e "s/<JPNIJ>/$jpnij/g" -e "s/<NXIOS>/$nxios/g" \
      -e "s/<NODES>/$nodes/g" -e "s/<NTASKS>/$ntasks/g" > includefile.ksh_${jpni}_${jpnj}_${jpnij}

set +x
. ./includefile.ksh_${jpni}_${jpnj}_${jpnij}
set -x

cat ./namelist.${CONFCASE}.tmp  | sed -e "s/<JPNI>/$jpni/g" -e "s/<JPNJ>/$jpnj/g" -e "s/<JPNIJ>/$jpnij/g" > namelist.${CONFCASE}_${jpni}_${jpnj}_${jpnij}
cat ./${CONFCASE}_occigen2.ksh.tmp2  | sed -e "s/<JPNI>/$jpni/g" -e "s/<JPNJ>/$jpnj/g" -e "s/<JPNIJ>/$jpnij/g" -e "s/<NXIOS>/$nxios/g" \
      -e "s/<NODES>/$nodes/g" -e "s/<NTASKS>/$ntasks/g" > ${SUBMIT_SCRIPT}

echo " All required tools and scripts copied on the home of production machine"
echo " submitting ${SUBMIT_SCRIPT} "

sbatch  ./${SUBMIT_SCRIPT}
