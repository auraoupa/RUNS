#!/bin/ksh
# automatically created post_processing script from
# function mk_post_process in function_3.2_all.ksh
          . /scratch/cnt0024/hmg2840/molines/DEV/RUN_TOOLS/function_3.2_all.ksh
          CONFIG=EORCA12.L75
          DDIR=/scratch/cnt0024/hmg2840/molines
          CONFIG_CASE=EORCA12.L75-scal
          CASE=scal
          member=$1
          ext=$2

          echo MEMBER $member
          lis_zoomid='Se19w
Se36n
Se48n
Se48w
alteAZO
alteAZOU
alteAZOV
alteLMX
alteLMXU
alteLMXV
alteOSM
alteOSMU
alteOSMV
alteREK
alteREKU
alteREKV
miniOSM'
          
          nnn=$(getmember_extension $member nodot)
          mmm=$(getmember_extension $member      )

          cd $DDIR/${CONFIG_CASE}-XIOS.$ext/$nnn
          if [ $nnn ] ; then
             ln -sf ../coordinates.nc ./
             ln -sf ../*xml ./
          fi
          for zoomid in $lis_zoomid ; do
             post_process_one_file $zoomid
          done
