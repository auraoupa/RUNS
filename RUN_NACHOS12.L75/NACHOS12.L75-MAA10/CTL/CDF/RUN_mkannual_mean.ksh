#!/bin/ksh
. ./config_moy.ksh

usage() {
    echo "  USAGE : $(basename $0 ) Y1 [Y2]"
    echo 
    echo "  Purpose:"
    echo "      This script is a wrapper to submit the computation of "
    echo "      annual mean from NEMO monthly mean "
    echo "      This script must be run from CTL/CDF dir"
    echo 
    echo " Arguments:"
    echo "   Y1 : first year to compute annual mean. "
    echo "   Y2 : last year to comput annual mean. If missing only work with Y1."
    exit
       }
HERE=$(pwd)
if [ $( basename $HERE ) != CDF ] ; then usage ; fi
if [ $# = 0 ] ; then usage ; fi

tmp=$(dirname `dirname $HERE` ) 
CONFCASE=$(basename $tmp)
CONFIG=$( echo $CONFCASE | awk -F- '{print $1}' )
CASE=$(   echo $CONFCASE | awk -F- '{print $2}' )
freq=$XIOS

y1=$1
y2=$2

y2=${y2:=$y1}

# eventually set -nc4 option for cdftools 
NC4=${NC4:=0}
if [ $NC4 = 1 ] ; then NCOPT='-nc4' ; else NCOPT="" ; fi

case $MACHINE in 
    ( curie )
submit=ccc_msub
# Only for curie for the moment
cat << eof > zmkannualmean.ksh
#!/bin/ksh
#MSUB -r anualmean
#MSUB -n  6
#MSUB -T 9200
#MSUB -q standard
#MSUB -o zannualmean.o%I
#MSUB -e zannualmean.e%I

#MSUB -A gen0727
cd \${BRIDGE_MSUB_PWD}
eof
echo " " ;; 
    ( * )
  echo " add support for $MACHINE  "
  exit 1 ;;
esac

#
cat << eof >> zmkannualmean.ksh
DTADIR=$REMDIR/${CONFIG}/${CONFCASE}-S/$freq

# functions 
gettyplist() {
    for f in ${CONFCASE}*m01.${freq}*.nc ; do
      typ=\${f##*_} ; typ=\${typ%.nc}
      if [ \$typ != VT ] ; then
        echo -n \$typ " "
      fi
    done
             }

# main
#   goto the MEAN directory
mkdir -p $DDIR/${CONFIG}/${CONFCASE}-MEAN/$freq/
cd $DDIR/${CONFIG}/${CONFCASE}-MEAN/$freq/   
#   loop on years to process
for y in \$(seq $y1 $y2 ) ; do
  # create year directory (if necessary) and cd to this directory
  mkdir -p \$y
  cd \$y
  # link monthly files already output with XIOS in the data dir ( may be from another user )
  ln -sf \$DTADIR/\$y/${CONFCASE}*nc ./

  # look for all available type of file (eg gridT gridU etc ...) to process ( VT files are excluded)
  typlist=\$( gettyplist)

  # loop on types
  for t in \$typlist ; do
     echo \$y \$t 

     # check if annual mean already exists
     if [ ! -f ${CONFCASE}_y\${y}.${freq}_\${t}.nc ] ; then 
       # prepare mpirun command to compute 6 temporary means files corresponding to 6 pairs of input files, and run it
       cmd="mpirun "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m0[12].${freq}_\${t}.nc -o tmpg12 : "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m0[34].${freq}_\${t}.nc -o tmpg34 : "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m0[56].${freq}_\${t}.nc -o tmpg56 : "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m0[78].${freq}_\${t}.nc -o tmpg78 : "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m09.${freq}_\${t}.nc ${CONFCASE}_y\${y}m10.${freq}_\${t}.nc -o tmpg910 : "
       cmd="\$cmd -np 1 cdfmoy -l ${CONFCASE}_y\${y}m1[12].${freq}_\${t}.nc -o tmpg1112 "
       \$cmd

       # prepare mpirun command to compute 3 temporary means files corresponding to 3 pairs of temporary mean from previous step, as
       #  well of mean squared values from previous step
       cmd="mpirun "
       cmd="\$cmd -np 1 cdfmoy -l tmpg12.nc tmpg34.nc -o tmpg_1 : -np 1 cdfmoy -l tmpg56.nc tmpg78.nc -o tmpg_2 : -np 1 cdfmoy -l tmpg910.nc tmpg1112.nc -o tmpg_3 :"
       cmd="\$cmd -np 1 cdfmoy -l tmpg122.nc tmpg342.nc -o tmpg_12 : -np 1 cdfmoy -l tmpg562.nc tmpg782.nc -o tmpg_22 : -np 1 cdfmoy -l tmpg9102.nc tmpg11122.nc -o tmpg_32 "
       \$cmd

       # final mpirun command to comput annual mean from 3 temporary files from previous step, as well as mean squared 
       cmd="mpirun "
       cmd="\$cmd -np 1 cdfmoy -l tmpg_1.nc tmpg_2.nc tmpg_3.nc $NCOPT -o  ${CONFCASE}_y\${y}.${freq}_\${t}mpp : -np 1 cdfmoy -l tmpg_12.nc tmpg_22.nc tmpg_32.nc $NCOPT -o  ${CONFCASE}_y\${y}.${freq}_\${t}2 "
       \$cmd
     
       # keep only meansquared for some types
       case \$t in
       ( gridT | gridU | gridV | gridW )
          echo " keep mean squared" ;;
       ( * )
          rm ${CONFCASE}_y\${y}.${freq}_\${t}2.nc ;;
       esac

       # remove useless temporary files, rename final results
       rm -f tmpg* ${CONFCASE}_y\${y}.${freq}_\${t}mpp2.nc cdfmoy2.nc *22.nc
       mv ${CONFCASE}_y\${y}.${freq}_\${t}mpp.nc ${CONFCASE}_y\${y}.${freq}_\${t}.nc 
     fi
  done
  cd ../
done

eof


$submit ./zmkannualmean.ksh
