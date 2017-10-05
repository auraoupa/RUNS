#!/bin/bash
#SBATCH -J zmergxios
#SBATCH --nodes=1
#SBATCH --ntasks=15
#SBATCH --ntasks-per-node=24
#SBATCH --time=3:00:00
#SBATCH -e zmergxios.e%j
#SBATCH -o zmergxios.o%j
#SBATCH --constraint=BDW28
#SBATCH --exclusive
      . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2.ksh
      . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2_all.ksh
         DDIR=/scratch/cnt0024/hmg2840/albert7a
         zXIOS=/scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75-MAA11-XIOS.2
         WKDIR=$zXIOS/WRK.49884
         mkdir -p $WKDIR
         cd $WKDIR
         mergeprog=mergefile_mpp4.exe
         # link all files in all member in a single dir
         for member in $(seq  -1 -1 ) ; do
            nnn=$(getmember_extension $member nodot)
            ln -sf $zXIOS/$nnn/NACHOS12.L75-MAA11*.nc ./
         done
         ln -sf  $zXIOS/coordinates.nc ./
         ln -sf /scratch/cnt0024/hmg2840/albert7a/bin/mergefile_mpp4.exe ./
         getlst0000 24000
         idxmax=$(( ${#lst0000[@]} - 1 )) #  index max in the list, starting from 0

         for idx in $( seq 0 $idxmax ) ; do
             runcode_u 15 ./$mergeprog -f ${lst0000[$idx]} -c coordinates.nc -r
         done
         \rm *.nc  # in WKDIR
