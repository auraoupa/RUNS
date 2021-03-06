#!/bin/ksh

## Important :
## To do this step, you must have completed monitor_prod and make_ncdf_timeseries

# We source the config_def and export them so that python can read them :
. ./config_def.ksh
. ./function_def.ksh

export MONPY_CONFIG=$CONFIG
export MONPY_CASE=$CASE
export MONPY_DATADIR=$MONITOR  
export MONPY_PLOTDIR=$PLOTDIR
export MONPY_DATAOBSDIR=$DATAOBSDIR

# ugly trick for ulam due to change in filesystem management
if [ $MACHINE == 'ulam' ] ; then MONPY_DATADIR=$SDIR/$MONPY_DATADIR ; fi

# Create the output directories tree :

chkdir $PLOTDIR/$CONFIG
chkdir $PLOTDIR/$CONFIG/PLOTS
chkdir $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}
chkdir $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}/TIME_SERIES

# Run the individual scripts :

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
    if [ $ts_tsmean == 1 ]      ; then tsmean.py      -f $freq_diags    ; fi
    if [ $ts_tsmean_lev == 1 ]  ; then tsmean_lev.py  -f $freq_diags    ; fi
    if [ $ts_tsmeanlat == 1 ]   ; then tsmeanlat.py   -f $freq_diags    ; fi
    if [ $ts_tslatn == 1 ]      ; then tslatn.py      -f $freq_diags    ; fi
    if [ $ts_tslats == 1 ]      ; then tslats.py      -f $freq_diags    ; fi
    if [ $ts_tslateq == 1 ]     ; then tslateq.py     -f $freq_diags    ; fi
    if [ $ts_trpsig == 1 ]      ; then trpsig.py      -f $freq_diags    ; fi

done


### copy to website
cd $PLOTDIR/$CONFIG/PLOTS/${CONFIG}-${CASE}/TIME_SERIES
copy_to_web *.png

# The end...
