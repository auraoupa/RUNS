#!/bin/ksh
#SBATCH -J zcpstorst
#SBATCH --nodes=1
#SBATCH --ntasks=14
#SBATCH --ntasks-per-node=28
#SBATCH --time=1:00:00
#SBATCH --constraint=BDW28
#SBATCH -e zcpstorst.e%j
#SBATCH -o zcpstorst.o%j
#SBATCH --exclusive

set -xv

CONFIG=EORCA12.L75
CASE=MJMgd16
typ=RST

CONFCASE=${CONFIG}-${CASE}
RDIR=$SDIR/${CONFIG}/${CONFCASE}-${typ}

mkdir -p $RDIR

cd $DDIR
lst=( $(ls -d ${CONFCASE}-*$typ.* ) )
cmd='mpirun ' ; n=0

# eliminate last one, likely being modified or empty during production
ndir=${#lst[@]}
#unset lst[$(( ndir - 1 ))]

#for d in ${CONFCASE}-${typ}.* ; do
for d in ${lst[@]}  ; do
   if [ ! -f $RDIR/$d.tar ] ; then
      n=$(( n + 1 ))
      cmd="$cmd -np 1 tar cf $RDIR/$d.tar $d :"
#      echo tar cf $RDIR/$d.tar $d
   fi
   if [ $n = 14 ] ; then 
      cmd=${cmd%:}
      n=0
      $cmd
      cmd='mpirun ' 
   fi
done


if [ $n != 0 ] ; then
      $cmd
fi
