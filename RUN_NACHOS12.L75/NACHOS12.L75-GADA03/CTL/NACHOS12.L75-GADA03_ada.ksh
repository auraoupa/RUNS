#!/bin/bash
# @ job_name = nemo_ada

##     Output listing location
# Fichier de sortie standard du travail  
# @ output = $(job_name).o$(jobid)
# @ error  = $(job_name).e$(jobid)
# @ job_type = mpich
# @ wall_clock_limit = 1:00:00
# @ total_tasks = 1986
# @ environment = MP_PROCS=$(total_tasks)
# @ environment = NB_NPROC=$(total_tasks)
# @ as_limit = 3.0gb
# @ queue

module load intel/2017.2

set -x
ulimit -s 
ulimit -s unlimited

CONFIG=NACHOS12.L75
CASE=GADA03

CONFCASE=${CONFIG}-${CASE}
CTL_DIR=$PDIR/RUN_${CONFIG}/${CONFCASE}/CTL

# Following numbers must be consistant with the header of this job
export NB_NPROC=1951    # number of cores used for NEMO
export NB_NPROC_IOS=35   # number of cores used for xios (number of xios_server.exe)
export NB_NCORE_DP=0    # activate depopulated core computation for XIOS. If not 0, RUN_DP is
                        # the number of cores used by XIOS on each exclusive node.
# Rebuild process 
export MERGE=0          # 1 = on the fly rebuild, 0 = dedicated job
export NB_NPROC_MER=15   # number of cores used for rebuild on the fly  (1/node is a good choice)
export NB_NNODE_MER=1   # number of nodes used for rebuild in dedicated job (MERGE=0). One instance of rebuild per node will be used.

date
#
echo " Read corresponding include file on the HOMEWORK "
.  ${CTL_DIR}/includefile.ksh

. $RUNTOOLS/function_3.2_all.ksh
. $RUNTOOLS/function_3.2.ksh

#  you can eventually include function redefinitions here (for testing purpose, for instance).
runcode_mpmd() {
n1=$1
n2=$3
prog1=$2
prog2=$4
   mpirun  -n $3 $4 : -n $1 $2

               }

. $RUNTOOLS/nemo3.4.ksh
