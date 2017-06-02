#!/bin/ksh
  if [ $# = 0 ] ; then
    echo usage $(basename $0 ) nemo_occigne2.exxxx file
    exit
  fi

loge=$1
logo=$( echo $loge | sed -e 's/\.e/.o/')
nseg=$(grep '^+ CONFIG=' $loge | wc -l )

if [ $nseg = 1 ] ; then
  echo nothing to do for $loge
else
  echo split $loge  in $nseg pieces
  # save date of original log files
  dat_e=$( ls --full-time $loge | awk '{ print $6 " "$7" " $8 }' )
  dat_o=$( ls --full-time $logo | awk '{ print $6 " "$7" " $8 }' )

  # get jobid
  jobid=${loge#*.e}
  lime=( $(grep -n '^+ CONFIG=' $loge                 | awk -F: '{ print $1 - 4 }' ) )
  limo=( $(grep -n 'Read corresponding include' $logo | awk -F: '{ print $1 - 2 }' ) )
  lime[$nseg]=10000000000
  limo[$nseg]=10000000000
  for n in $(seq 1 $nseg) ; do
    nm1=$(( n - 1 ))
    fe=${loge}-$n
    fo=${logo}-$n
    le1=${lime[$nm1]}
    lo1=${limo[$nm1]}
    le2=$(( ${lime[$n]} ))
    lo2=$(( ${limo[$n]} ))
    # split loge file 
    cat $loge | awk '{ if ( NR >= le1 && NR < le2 ) print $0 }' le1=$le1 le2=$le2 > $fe


    # split logo file 
    cat $logo | awk '{ if ( NR >= lo1 && NR < lo2 ) print $0 }' lo1=$lo1 lo2=$lo2 > $fo

    # reset date on logo
    # reset date on loge
    dat_file=$(tail -3  $fo  | head -1)
    touch -d "$dat_file" $fe
    touch -d "$dat_file" $fo
  done
  # rename original file
  mv $loge  o-$loge
  mv $logo  o-$logo
fi
