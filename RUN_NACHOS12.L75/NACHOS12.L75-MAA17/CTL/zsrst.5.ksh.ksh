#!/bin/ksh
   set -x
   . ./includefile.ksh
   . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2_all.ksh
   . /scratch/cnt0024/hmg2840/albert7a/DEV/RUN_TOOLS/function_3.2.ksh

   # set local variables as in nemo3.4 (calling script)
   ext=5
   AGRIF=0
   XIOS=1
   DIMGOUT=0
   nst_lst=" "
   mmm=
   zrstdir=/scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75-MAA17-RST.5/

   # O C E A N
   # *********
   OCE_RST_IN=$(LookInNamelist cn_ocerst_in namelist_oce.5)
   OCE_RST_OUT=$(LookInNamelist cn_ocerst_out namelist_oce.5)

   mktarrst $OCE_RST_IN $OCE_RST_OUT _oce_v2

   # send them on DATA space
   cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
   for f in ${OCE_RST_OUT}_oce_v2.5.tar.*  ; do
      expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
   done
   if [ 0 = 1 ] ; then
     for idx in   ; do 
       for f in ${idx}_${OCE_RST_OUT}_oce_v2.5.tar.*  ; do
          expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
       done
     done
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17

   # I C E
   # *****
   if [ 1 = 1 ] ; then
     ICE_RST_IN=$(LookInNamelist cn_icerst_in namelist_ice.5)
     ICE_RST_OUT=$(LookInNamelist cn_icerst_out namelist_ice.5)

     mktarrst $ICE_RST_IN $ICE_RST_OUT _v2

   # send them on DATA space
    cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
    for f in ${ICE_RST_OUT}_v2.5.tar.*  ; do
       expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
    done
    if [ 0 = 1 ] ; then
    for idx in   ; do 
      for f in ${idx}_${ICE_RST_OUT}_v2.5.tar.*  ; do
         expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      done
    done
    fi
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17

   # P A S S I V E   T R A C E R S
   # *****************************
   if [ 0 = 1 ] ; then
     TRC_RST_IN=$(LookInNamelist   cn_trcrst_in namelist_top.5)
     TRC_RST_OUT=$(LookInNamelist cn_trcrst_out namelist_top.5)

     mktarrst $TRC_RST_IN $TRC_RST_OUT _v2
  
    # send them on  DATA space
    cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
    for f in ${TRC_RST_OUT}_v2.5.tar.*  ; do
      expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
    done
    if [ 0 = 1 ] ; then
      for idx in   ; do 
        for f in ${idx}_${TRC_RST_OUT}_v2.5.tar.*  ; do
           expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
        done
      done
    fi
   fi
   cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17
  
   # T R D  M L D
   # ************
   if [ 0 = 1 ] ; then
      TRD_RST_IN=$(LookInNamelist cn_trdrst_in namelist_oce.5)
      TRD_RST_OUT=$(LookInNamelist cn_trdrst_out namelist_oce.5)
  
      mktarrst $TRD_RST_IN $TRD_RST_OUT _v2
  
      # send them on  DATA space
      cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      for f in ${TRD_RST_OUT}_v2.5.tar.*  ; do
         expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      done
      if [ 0 = 1 ] ; then
         for idx in   ; do 
            for f in ${idx}_${TRD_RST_OUT}_v2.5.tar.*  ; do
               expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
            done
         done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17
   fi

   # S T O 
   # *****
   if [ 0 = 1 ] ; then
      STO_RST_IN=$(LookInNamelist cn_storst_in namelist_oce.5)
      STO_RST_OUT=$(LookInNamelist cn_storst_out namelist_oce.5)
      mktarrst $STO_RST_IN $STO_RST_OUT _v2
  
      # send them on  DATA space
      cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      for f in ${STO_RST_OUT}_v2.5.tar.*  ; do
         expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      done
     if [ 0 = 1 ] ; then
        for idx in   ; do 
           for f in ${idx}_${STO_RST_OUT}_v2.5.tar.*  ; do
              expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
           done
        done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17
   fi

   # I C B 
   # *****
   if [ 0 = 1 ] ; then
      ICB_RST_IN=restart_icebergs
      ICB_RST_OUT=icebergs_restart
      mktarrst $ICB_RST_IN $ICB_RST_OUT _v2
  
      # send them on  DATA space
      cd /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      for f in ${ICB_RST_OUT}_v2.5.tar.*  ; do
         expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
      done
     if [ 0 = 1 ] ; then
        for idx in   ; do 
           for f in ${idx}_${ICB_RST_OUT}_v2.5.tar.*  ; do
              expatrie_res $f /store/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R $f /scratch/cnt0024/hmg2840/albert7a/NACHOS12.L75/NACHOS12.L75-MAA17-R
           done
        done
     fi
     cd /scratch/cnt0024/hmg2840/albert7a/TMPDIR_NACHOS12.L75-MAA17
   fi

   touch RST_DONE.5
