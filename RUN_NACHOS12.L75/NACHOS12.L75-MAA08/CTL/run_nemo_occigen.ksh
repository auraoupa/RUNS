#!/bin/bash
date
set -x
##############################################
#  wrapper for submitting LL script on ada
##############################################

if [ ! $PDIR ] ; then
   echo "You must set up your environment for DCM before using the RUN_TOOLS"
   echo PDIR environment variable not set
   exit 1
fi
CONFIG=NACHOS12.L75
CASE=MAA08
CONFCASE=${CONFIG}-${CASE}

set +x
. ./includefile.ksh

echo " All required tools and scripts copied on the home of production machine"
echo " submitting ${SUBMIT_SCRIPT} "

sbatch  ./${SUBMIT_SCRIPT}
