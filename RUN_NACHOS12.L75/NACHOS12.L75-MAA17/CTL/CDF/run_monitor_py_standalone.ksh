#!/bin/ksh
## =====================================================================
##     ***  script run_monitor_py_standalone.ksh   ***
##  perform monitor.py in a standalone way ( local definition inside this
##  script). Do not use config_def.ksh settings.
##  Important :
## To do this step, you must have completed monitor_prod and make_ncdf_timeseries
## =====================================================================
## History : 1.0  !  2010     R. Dussin, J. Le Sommer   Original code
##  DMONTOOLS_2.0 , MEOM 2012
##  $Id: run_monitor_py_standalone.ksh 618 2015-03-22 08:13:01Z molines $
##  Copyright (c) 2012, J.-M. Molines
##  Software governed by the CeCILL licence (Licence/DMONTOOLSCeCILL.txt)
## ----------------------------------------------------------------------

# copy_to_web : copy the time series figures to the DRAKKAR website
# usage : copy_to_web file
copy_to_web() {
          ssh meolipc.legi.grenoble-inp.fr -l drakkar \
         " if [ ! -d DRAKKAR/$CONFIG/${CONFIG}-${CASE}/TIME_SERIES ] ; then mkdir -p DRAKKAR/$CONFIG/${CONFIG}-${CASE}/TIME_SERIES ; fi "
          scp $@ drakkar@meolipc.legi.grenoble-inp.fr:DRAKKAR/$CONFIG/${CONFIG}-${CASE}/TIME_SERIES/ ;}

# CHKDIR  : check the existence of a directory. Create it if not present
chkdir() { if [ ! -d $1 ] ; then mkdir $1 ; fi  ; }

######################################################################################

CONFIG=NACHOS12.L75
CASE=MAA17
MONITOR=$WORKDIR/$CONFIG/${CONFIG}-${CASE}-MONITOR
PLOTDIR=$WORKDIR
DATAOBS=$PYDMON_DATADIR

WEBCOPY=true # or false

ts_cable=0
ts_gib=0
ts_icemonth=0
ts_icenoaa=0
ts_icetrd=0
ts_maxmoc=0
ts_maxmoc40=0
ts_mht1=0
ts_nino=0
ts_tao=0
ts_transports1=0
ts_trpsig=0
ts_tsmean=0
ts_tslatn=0
ts_tslateq=0
ts_tslats=0
ts_tsmeanlat=0
ts_tsmean_lev=0
ts_mld_kerg=0
ts_ice_kerg=0 
ts_hov_kerg=0 
ts_bio_kerg=0

#############################################################################

export MONPY_CONFIG=$CONFIG
export MONPY_CASE=$CASE
export MONPY_DATADIR=$MONITOR  
export MONPY_PLOTDIR=$PLOTDIR
export MONPY_DATAOBSDIR=$DATAOBS

chkdir $PLOTDIR/$CONFIG
chkdir $PLOTDIR/$CONFIG/PLOTS
chkdir $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}
chkdir $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}/TIME_SERIES

## Monthly diags
if [ $ts_icemonth == 1 ]    ; then icemonth.py     ; fi
if [ $ts_icenoaa == 1 ]     ; then icenoaa.py      ; fi
if [ $ts_nino == 1 ]        ; then nino.py         ; fi
if [ $ts_mld_kerg == 1 ]    ; then mldkerg.py      ; fi
if [ $ts_ice_kerg == 1 ]    ; then icekerg.py      ; fi
if [ $ts_hov_kerg == 1 ]    ; then hovkerg.py      ; fi
if [ $ts_bio_kerg == 1 ]    ; then chlkerg.py; co2kerg.py; nutkerg.py; ppkerg.py; fi

## Annual diags
if [ $ts_icetrd == 1 ]      ; then icetrd.py       ; icetrd_min.py  ; fi
if [ $ts_tao == 1 ]         ; then tao_profiles.py ; tao_undercurrent.py ; fi

## Multi-freq diags
list_freq='1m 1y'

for freq_diags in $list_freq ; do

    if [ $ts_cable == 1 ]       ; then cable.py       -f $freq_diags    ; fi
    if [ $ts_gib == 1 ]         ; then gib.py         -f $freq_diags    ; fi
    if [ $ts_maxmoc == 1 ]      ; then maxmoc.py      -f $freq_diags    ; fi
    if [ $ts_maxmoc40 == 1 ]    ; then maxmoc40.py    -f $freq_diags    ; fi
    if [ $ts_mht1 == 1 ]        ; then mht1.py        -f $freq_diags    ; fi
    if [ $ts_transports1 == 1 ] ; then transports1.py -f $freq_diags    ; fi
    if [ $ts_trpsig == 1 ]      ; then trpsig.py      -f $freq_diags    ; fi
    if [ $ts_tsmean == 1 ]      ; then tsmean.py      -f $freq_diags    ; fi
    if [ $ts_tsmeanlat == 1 ]   ; then tsmeanlat.py   -f $freq_diags    ; fi
    if [ $ts_tslatn == 1 ]      ; then tslatn.py      -f $freq_diags    ; fi
    if [ $ts_tslats == 1 ]      ; then tslats.py      -f $freq_diags    ; fi
    if [ $ts_tslateq == 1 ]     ; then tslateq.py     -f $freq_diags    ; fi
    if [ $ts_tsmean_lev == 1 ]  ; then tsmean_lev.py  -f $freq_diags    ; fi

done

### copy to website
if [ $WEBCOPY == 'true' ] ; then

   cd $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}/TIME_SERIES
   copy_to_web *.png

fi
### The end
