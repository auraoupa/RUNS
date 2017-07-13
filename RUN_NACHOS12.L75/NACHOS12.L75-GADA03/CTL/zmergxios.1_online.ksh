#!/bin/bash
# @ job_name = zmergxios
# @ output = $(job_name).o$(jobid)
# @ error  = $(job_name).e$(jobid)
# @ job_type = serial
# @ requirements = (Feature == "prepost")
# @ wall_clock_limit=3:00:00
# @ as_limit = 3.5gb
# @ queue
      . /workgpfs/rech/ote/rote001/DEV/RUN_TOOLS/function_3.2.ksh
      . /workgpfs/rech/ote/rote001/DEV/RUN_TOOLS/function_3.2_all.ksh
         DDIR=/workgpfs/rech/ote/rote001
         zXIOS=/workgpfs/rech/ote/rote001/NACHOS12.L75-GADA03-XIOS.1
         WKDIR=$zXIOS/WRK.62087
         mkdir -p $WKDIR
         cd $WKDIR
         mergeprog=mergefile4.exe
         # link all files in all member in a single dir
         for member in $(seq  -1 -1 ) ; do
            nnn=$(getmember_extension $member nodot)
            ln -sf $zXIOS/$nnn/NACHOS12.L75-GADA03*.nc ./
         done
         ln -sf  $zXIOS/coordinates.nc ./
         ln -sf /workgpfs/rech/ote/rote001/bin/$mergeprog ./
         getlst0000 24000
         idxmax=$(( ${#lst0000[@]} - 1 )) #  index max in the list, starting from 0

         for idx in $( seq 0 $idxmax ) ; do
             ./$mergeprog -f ${lst0000[$idx]} -c coordinates.nc -r
         done
         \rm *.nc  # in WKDIR
