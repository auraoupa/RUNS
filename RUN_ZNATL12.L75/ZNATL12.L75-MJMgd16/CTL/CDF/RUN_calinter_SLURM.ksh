#!/bin/ksh
if [ $# = 0 ] ; then
   echo USAGE: RUN_calinter.ksh  year1 year2
   exit 1
fi
#set -x

# get configuration settings
. ./config_moy.ksh
. ./function_moy.ksh

# set additional variables
mkdir -p  $WPDIR


# copy required scripts there:
cp -f config_moy.ksh $WPDIR
cp -f function_moy.ksh $WPDIR

# get year to work with
year1=$1
year2=$2


cat << eof > zcalinter_${year1}-${year2}
#!/bin/ksh
#MSUB -r zint_${year1}-${year2}
#MSUB -n  1
#MSUB -T 3600
#MSUB -q $QUEUE
#MSUB -o zint_${year1}-${year2}.%I
#MSUB -e zint_${year1}-${year2}.%I
#MSUB -A $ACCOUNT

CTL_DIR=$WPDIR
cd \$CTL_DIR
. ./config_moy.ksh
. ./function_moy.ksh

interannual $year1 $year2

eof

ccc_msub  zcalinter_${year1}-${year2}


