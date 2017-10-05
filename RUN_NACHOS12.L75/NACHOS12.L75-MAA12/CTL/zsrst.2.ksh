#!/bin/bash
#SBATCH -J zsrst
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=2:00:00
#SBATCH -e zsrst.e%j
#SBATCH -o zsrst.o%j
#SBATCH --constraint=BDW28
#SBATCH --exclusive
 set -x
 cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12
 . ./includefile.ksh
 . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2_all.ksh
 . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2.ksh
 srcbash # just in case
 # set local variables as in nemo3.4 (calling script)
 ext=2
 AGRIF=0
 XIOS=1
 DIMGOUT=0
 RST_DIRS=1
 nst_lst=" "

 mpmd_arg=""
 for member in $(seq -1 -1) ; do
   mmm=$(getmember_extension $member)
   nnn=$(getmember_extension $member nodot )
   zrstdir='./'
   if [ $RST_DIRS = 1 ] ; then zrstdir=/scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75-MAA12-RST.$ext/$nnn ; fi
   # create secondary scripts to be submitted in // trhough the members
   # $ to be maintained in the final script are replaces by @, then automatic edition
   # replace the @ by $ [ this is necessary because we are at the second level od script
   # creation !
   cat << eof1 > ztmp
#!/bin/ksh
   set -x
   . ./includefile.ksh
   . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2_all.ksh
   . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2.ksh

   # set local variables as in nemo3.4 (calling script)
   ext=2
   AGRIF=0
   XIOS=1
   DIMGOUT=0
   nst_lst=" "
   mmm=$mmm
   zrstdir=$zrstdir

   # O C E A N
   # *********
   OCE_RST_IN=@(LookInNamelist cn_ocerst_in namelist_oce.2)$mmm
   OCE_RST_OUT=@(LookInNamelist cn_ocerst_out namelist_oce.2)$mmm

   mktarrst @OCE_RST_IN @OCE_RST_OUT _oce_v2

   # send them on DATA space
   cd $P_R_DIR
   for f in @{OCE_RST_OUT}_oce_v2.$ext.tar.*  ; do
      expatrie_res @f $F_R_DIR @f $P_R_DIR
   done
   if [ 0 = 1 ] ; then
     for idx in $nst_lst ; do 
       for f in @{idx}_@{OCE_RST_OUT}_oce_v2.$ext.tar.*  ; do
          expatrie_res @f $F_R_DIR @f $P_R_DIR
       done
     done
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12

   # I C E
   # *****
   if [ 1 = 1 ] ; then
     ICE_RST_IN=@(LookInNamelist cn_icerst_in namelist_ice.2)$mmm
     ICE_RST_OUT=@(LookInNamelist cn_icerst_out namelist_ice.2)$mmm

     mktarrst @ICE_RST_IN @ICE_RST_OUT _v2

   # send them on DATA space
    cd $P_R_DIR
    for f in @{ICE_RST_OUT}_v2.$ext.tar.*  ; do
       expatrie_res @f $F_R_DIR @f $P_R_DIR
    done
    if [ 0 = 1 ] ; then
    for idx in $nst_lst ; do 
      for f in @{idx}_@{ICE_RST_OUT}_v2.$ext.tar.*  ; do
         expatrie_res @f $F_R_DIR @f $P_R_DIR
      done
    done
    fi
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12

   # P A S S I V E   T R A C E R S
   # *****************************
   if [ 0 = 1 ] ; then
     TRC_RST_IN=@(LookInNamelist   cn_trcrst_in namelist_top.2)$mmm
     TRC_RST_OUT=@(LookInNamelist cn_trcrst_out namelist_top.2)$mmm

     mktarrst @TRC_RST_IN @TRC_RST_OUT _v2
  
    # send them on  DATA space
    cd $P_R_DIR
    for f in @{TRC_RST_OUT}_v2.$ext.tar.*  ; do
      expatrie_res @f $F_R_DIR @f $P_R_DIR
    done
    if [ 0 = 1 ] ; then
      for idx in $nst_lst ; do 
        for f in @{idx}_@{TRC_RST_OUT}_v2.$ext.tar.*  ; do
           expatrie_res @f $F_R_DIR @f $P_R_DIR
        done
      done
    fi
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12
  
   # T R D  M L D
   # ************
   if [ 0 = 1 ] ; then
      TRD_RST_IN=@(LookInNamelist cn_trdrst_in namelist_oce.2)$mmm
      TRD_RST_OUT=@(LookInNamelist cn_trdrst_out namelist_oce.2)$mmm
  
      mktarrst @TRD_RST_IN @TRD_RST_OUT _v2
  
      # send them on  DATA space
      cd $P_R_DIR
      for f in @{TRD_RST_OUT}_v2.$ext.tar.*  ; do
         expatrie_res @f $F_R_DIR @f $P_R_DIR
      done
      if [ 0 = 1 ] ; then
         for idx in $nst_lst ; do 
            for f in @{idx}_@{TRD_RST_OUT}_v2.$ext.tar.*  ; do
               expatrie_res @f $F_R_DIR @f $P_R_DIR
            done
         done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12
   fi

   # S T O 
   # *****
   if [ 0 = 1 ] ; then
      STO_RST_IN=@(LookInNamelist cn_storst_in namelist_oce.2)$mmm
      STO_RST_OUT=@(LookInNamelist cn_storst_out namelist_oce.2)$mmm
      mktarrst @STO_RST_IN @STO_RST_OUT _v2
  
      # send them on  DATA space
      cd $P_R_DIR
      for f in @{STO_RST_OUT}_v2.$ext.tar.*  ; do
         expatrie_res @f $F_R_DIR @f $P_R_DIR
      done
     if [ 0 = 1 ] ; then
        for idx in $nst_lst ; do 
           for f in @{idx}_@{STO_RST_OUT}_v2.$ext.tar.*  ; do
              expatrie_res @f $F_R_DIR @f $P_R_DIR
           done
        done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12
   fi

   # I C B 
   # *****
   if [ 0 = 1 ] ; then
      ICB_RST_IN=restart_icebergs$mmm
      ICB_RST_OUT=icebergs_restart$mmm
      mktarrst @ICB_RST_IN @ICB_RST_OUT _v2
  
      # send them on  DATA space
      cd $P_R_DIR
      for f in @{ICB_RST_OUT}_v2.$ext.tar.*  ; do
         expatrie_res @f $F_R_DIR @f $P_R_DIR
      done
     if [ 0 = 1 ] ; then
        for idx in $nst_lst ; do 
           for f in @{idx}_@{ICB_RST_OUT}_v2.$ext.tar.*  ; do
              expatrie_res @f $F_R_DIR @f $P_R_DIR
           done
        done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA12
   fi

   touch RST_DONE${mmm}.$ext
eof1
   cat ztmp | sed -e 's/@/$/g' > ./zsrst.2.ksh${mmm}.ksh    # change @ into $ and create script for current member
   chmod 755 ./zsrst.2.ksh${mmm}.ksh                         # made it executable

   mpmd_arg="$mpmd_arg 1 ./zsrst.2.ksh${mmm}.ksh"           # prepare the command line for runcode function
 done
  
  pwd
  if [ ! $mmm ] ; then
     ./zsrst.2.ksh${mmm}.ksh                                 # not an ensemble run : serial process
  else
     runcode_mpmd  $mpmd_arg                        # launch the scripts in parallele (mpmd mode)
  fi
