#!/bin/ksh
## =====================================================================
##     ***  script  RUN_plot_monitor.ksh  ***
##  This is a wrapper for submitting  plot_monitor.sub
## =====================================================================
## History : 1.0  !  20O8     J.M. Molines      Original code
## ----------------------------------------------------------------------

## ----------------------------------------------------------------------
##  DMONTOOLS_2.0 , MEOM 2012
##  $Id: RUN_plot_monitor.ksh 623 2015-06-08 12:01:13Z molines $
##  Copyright (c) 2012, J.-M. Molines
##  Software governed by the CeCILL licence (Licence/DMONTOOLSCeCILL.txt)
## ----------------------------------------------------------------------

if [ $#  = 0 ] ; then
   echo USAGE: RUN_plot_monitor.ksh year-init year-end
   echo "     or "
   echo "      RUN_plot_monitor.ksh year1-year2 "
   echo "       this last form makes plots for the climatology  year1-year2 (single plots)"
   exit 0
fi

  if [ $# = 2 ] ; then
    single=0
    year1=$1 ;  year2=$2
  else
    single=1
    year1=$1 ; year2=$1
  fi
    

set -x 
. ./config_def.ksh
. ./function_def.ksh

cp $PLOTTOOLS/make_movies.ksh     .
cp $PLOTTOOLS/make_movies_trc.ksh .
cp $PLOTTOOLS/cp2web_climgif.ksh .


if [ $RNDTMPDIR == 0 ] ; then

  # move elementary scripts to the local TMPDIR
  chkdir $P_MONITOR
  XTMPDIR=$P_MONITOR
  cp ./config_def.ksh           $XTMPDIR
  cp ./function_def.ksh         $XTMPDIR

  # copy  the Palette directory and the main plotting script
  cp -rf $PLOTTOOLS/PALDIR           $XTMPDIR
  cp     $PLOTTOOLS/plot_monitor.ksh $XTMPDIR

fi

  JOBTYPE=serial # this is the default (only for LoadLeveler)
  TASKTRICK='#'

  NB_NODES=1

  if [ $useMPI == 1 ] ; then
     cp $MPITOOLS/mpi_plot_monitor      $XTMPDIR
     JOBTYPE=parallel # we switch to parallel (only for LoadLeveler)
     TASKTRICK=''

     if [ $single =  0 ] ; then
       NB_NPROC=$(( year2 - year1 + 1 ))
     else
       NB_NPROC=1
     fi
     # compute the required number of nodes (assuming MPIPROC cores on 1 node)
     NB_NODES=$(( NB_NPROC / MPIPROC ))
     if (( NB_NPROC % MPIPROC != 0 )) ; then NB_NODES=$(( NB_NODES + 1 )) ; fi

     echo This job is asking for $NB_NODES nodes and $NB_NPROC cores
  fi


  # submit the monitoring mpi 
 cat $PLOTTOOLS/plot_monitor.skel.sub | sed  -e "s/#$MACHINE/#PBS/" \
     -e "s@<P_MONITOR>@$P_MONITOR@" \
     -e "s/<year1>/$year1/" -e "s/<year2>/$year2/" \
     -e "s/<NB_NODES>/$NB_NODES/" -e "s/<MAIL>/$MAIL/" \
     -e "s/<NB_NPROC>/$NB_NPROC/" -e "s/<PLOT_WALLTIME>/$PLOT_WALLTIME/" \
     -e "s/<JOBTYPE>/$JOBTYPE/"   -e "s/<MPIPROC>/$MPIPROC/g" \
     -e "s/<ACCOUNT>/$ACCOUNT/"   -e "s/<QUEUE>/$QUEUE/g" \
     -e "s/ifloadlev#/$TASKTRICK/g" -e "s/<RNDTMPDIR>/$RNDTMPDIR/" -e "s/<NODETYPE>/$NODETYPE/g"  >  plot_monitor.sub
 chmod +x plot_monitor.sub
 submit  ./plot_monitor.sub
 \rm plot_monitor.sub
