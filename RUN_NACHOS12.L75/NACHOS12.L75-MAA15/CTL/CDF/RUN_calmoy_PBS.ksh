#!/bin/ksh
# RUN_calmoy version for PBS on JADE 
if [ $# = 0 ] ; then
   echo USAGE: RUN_calmoy.ksh  year
   exit 1
fi
set -x

# get configuration settings
. ./config_moy.ksh
. ./function_moy.ksh

pbsext=pbs

# set additional variables WPDIR set in config_moy
mkdir -p $WPDIR

# copy required scripts there:
cp -f config_moy.ksh $WPDIR
cp -f function_moy.ksh $WPDIR

cp -f $MPDIR/mvcalmoy.ksh $WPDIR
cp -f $MPDIR/calannual.ksh $WPDIR

# get year to work with
year=$1

#prepare the 12 scripts in WPDIR

for m in $(seq 1 12 ) ; do
  mm=$(printf "%02d" $m )
  cat $MPDIR/calmoy_mm.ksh | sed -e "s/<year>/$year/g" -e "s/<mm>/$mm/g" -e "s/<m>/$m/g" > $WPDIR/zz_calmoy_${mm}_$year.ksh
  chmod 755 $WPDIR/zz_calmoy_${mm}_$year.ksh
done

# submit calmoy.$pbsext
cat $MPDIR/calmoy.$pbsext | sed -e "s/$MACHINE/PBS/" \
                   -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" -e "s/<year>/$year/g" \
                   -e "s@<WPDIR>@$WPDIR@" \
                   -e "s@<MPITOOLS>@$MPITOOLS@"  > zcalmoy.$pbsext

jobidmoy=$(qsub zcalmoy.$pbsext)

\rm zcalmoy.$pbsext

#prepare the 12 scripts in WPDIR

for m in $(seq 1 12 ) ; do
  mm=$(printf "%02d" $m )
  cat $MPDIR/calmoyvt_mm.ksh | sed -e "s/<year>/$year/g" -e "s/<mm>/$mm/g" -e "s/<m>/$m/g" > $WPDIR/zz_calmoyvt_${mm}_$year.ksh
  chmod 755 $WPDIR/zz_calmoyvt_${mm}_$year.ksh
done

# submit calmoyvt.$pbsext
cat $MPDIR/calmoyvt.$pbsext | sed  -e "s/$MACHINE/PBS/" \
                   -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" -e "s/<year>/$year/g" \
                   -e "s@<WPDIR>@$WPDIR@" \
                   -e "s@<MPITOOLS>@$MPITOOLS@" > zcalmoyvt.$pbsext
jobidvt=$(qsub zcalmoyvt.$pbsext)

\rm zcalmoyvt.$pbsext

# submit calanual script with dependencies afterok on jobidmoy and jobidvt

cat $MPDIR/calannual.$pbsext | sed -e "s/$MACHINE/PBS/" \
     -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" \
     -e "s/<JOBIDMOY>/$jobidmoy/" -e  "s/<JOBIDVT>/$jobidvt/" -e "s/<year>/$year/g" \
     -e "s@<WPDIR>@$WPDIR@"  > zcalannual_$year.$pbsext

qsub zcalannual_$year.$pbsext

