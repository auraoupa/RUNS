#!/bin/ksh
if [ $# = 0 ] ; then
   echo USAGE: RUN_calmoy.ksh year
   exit 1
fi

# get year to work with
year=$1

#####################################################
# get configuration settings
. ./config_moy.ksh
. ./function_moy.ksh

NPROC=$(( 12 / $STEP ))

cat $MPDIR/calmoy.skel.ll      | sed -e "s/<YYYY>/$year/g" > calmoy.ll.$$

cat $MPDIR/calmoyvt.skel.ll    | sed -e "s/<YYYY>/$year/g" > calmoyvt.ll.$$

cat $MPDIR/meta_calmoy.skel.ll | sed -e "s/<CDFMOY>/calmoy.ll.$$/"    \
                                     -e "s/<CDFVT>/calmoyvt.ll.$$/"   \
                                     -e "s/<NPROC>/$NPROC/"           \
                                 > meta_calmoy.ll.$year


llsubmit ./meta_calmoy.ll.$year

#\rm -f  calmoy.ll.$$ calmoyvt.ll.$$ calannual.ll.$$ meta_calmoy.ll.$year
