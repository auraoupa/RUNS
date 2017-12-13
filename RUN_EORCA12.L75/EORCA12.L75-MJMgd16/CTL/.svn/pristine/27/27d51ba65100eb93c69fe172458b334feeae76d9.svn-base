#!/bin/ksh
#SBATCH -J zcpstoicb
#SBATCH --nodes=1
#SBATCH --ntasks=14
#SBATCH --ntasks-per-node=28
#SBATCH --time=2:00:00
#SBATCH --constraint=BDW28
#SBATCH -e zcpstoicb.e%j
#SBATCH -o zcpstoicb.o%j
#SBATCH --exclusive

set -vx

CONFIG=EORCA12.L75
CASE=MJMgd16
typ=ICB

CONFCASE=${CONFIG}-${CASE}
RDIR=$SDIR/${CONFIG}/${CONFCASE}-${typ}

mkdir -p $RDIR

cd $DDIR
lst=( $(ls -1d ${CONFCASE}-*$typ.* | sort -t. -k3n) )
cmd='mpirun ' ; n=0

# eliminate lastone
ndir=${#lst[@]}
#unset lst[$(( ndir - 1 ))]

#for d in ${CONFCASE}-${typ}.* ; do
for d in ${lst[@]}  ; do
   if [ ! -f $RDIR/$d.tar ] ; then
      cd $d
      rm icebergs.stat_*
      cd -
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
