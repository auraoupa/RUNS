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
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=24
#SBATCH --constraint=HSW24
#SBATCH --threads-per-core=1
#SBATCH -J zint_${year1}-${year2}
#SBATCH -e zint_${year1}-${year2}.e%j
#SBATCH -o zint_${year1}-${year2}.o%j
#SBATCH --time=5:00:00
#SBATCH --exclusiv


ulimit -s unlimited
CTL_DIR=$WPDIR
cd \$CTL_DIR
. ./config_moy.ksh
. ./function_moy.ksh

interannual $year1 $year2

eof

sbatch  zcalinter_${year1}-${year2}


