#!/bin/ksh
#QSUB -eo
#QSUB -lT 3600 -lM 1gb  -l mpp_p=4

#PBS -N zz-make_movies
#PBS -l select=1:ncpus=8:mpiprocs=8
#PBS -l walltime=20:00:00
#PBS -l place=scatter:excl
##PBS -M molines@legi.grenoble-inp.fr
#PBS -mb -me

### LoadLeveler on ULAM and VARGAS
## title of the run
# @ job_name = zz-make_movies
## Output listing location
# @ output = $(job_name).$(jobid)
# @ error  = $(output)
# @ job_type = serial
# @ wall_clock_limit = 72000
# @ as_limit = 2.0gb
# @ queue

#set -x

#-------------------------------------------------------------------------------
#  $Date: 2009-03-03 (Tue, 03 Mar 2009) $
#  $History: (03/2009) adapted to PERIANT configurations by C. Dufour $
#            (04/2009) adapted to the new LEGI web host $
#-------------------------------------------------------------------------------

. ./config_def.ksh
. ./function_def.ksh

copy() {
          ssh drakkar@meolipc.legi.grenoble-inp.fr -l drakkar \
         " if [ ! -d DRAKKAR/$CONFIG/$CONFCASE/${dir} ] ; then mkdir -p DRAKKAR/$CONFIG/$CONFCASE/${dir} ; fi "
          scp $gifmov drakkar@meolipc.legi.grenoble-inp.fr:DRAKKAR/$CONFIG/${CONFCASE}/${dir}/$gifmov ;}

mkgif() {
            ctrans -device sun -res 1024x1024 $1 > p.sun
            convert p.sun p.gif 
            mv p.gif GIFS/$2
        }
         


cd $PLOTDIR/$CONFIG/PLOTS/$CONFCASE                             # work on ergon directly

 for dir in ATLANTIC OVT CFC GLOBAL DRAKE CAMPBELL KERGUELEN MEDSEA SECTIONS SECTIONS1 CIRCUM ICE DWBC MXL ATLN ATLS CONTOURS ; do
    if [ -d $dir ] ; then 
    cd $dir
    chkdir GIFS  # this directory should exist but who knows ...?

    # determine the different type of plots from reference year cgms
    for  type in $( ls | grep ANNUAL-${CASE}.cgm  | sed -e "s/_...._ANNUAL-${CASE}.cgm//" \
                    | sort -u ) $( ls | grep ._....-${CASE}.cgm \
                    | sed -e "s/_....-${CASE}.cgm//" | sort -u )   ; do
      if [ -f ${type}-${CASE}.catalog ] ; then 
        lastdone=$( tail -1 ${type}-${CASE}.catalog )
        #todo=$( echo $lastdone | awk '{ printf "%04d", $1  + 1 }' )
        todo=$( echo $lastdone | awk '{ print $1  + 1 }' )
        init=0
      else
        init=1
        # initialize todo to the first year of this type
        tmp=$( ls  ${type}_*.cgm | head -1 ) ;todo=$( echo ${tmp#${type}_} | cut -c 1-4 )
      fi

      last=$( ls -r ${type}_*.cgm | head -1 )
      until=$( echo ${last#${type}_} | cut -c 1-4 )
      echo working in $dir for  type  $type , year $todo  to  $until

        year=$todo
        if  (( $year > $until )) ; then  echo nothing to do for $type ; fi

        while [ $year -le  $until  ] ; do
          yearnnnn=$( printf "%04d"  $year )
          echo $year
          cgm=${type}_${yearnnnn}*${CASE}.cgm 
          gif=${cgm%.cgm}.gif
          gifmov=$( echo $cgm | sed -e "s/$yearnnnn/MONITOR/" -e 's/.cgm/.gif/'  )
          if [ -f $cgm  ] ; then
           if [ ! -f GIFS/$gif ] ; then
            mkgif $cgm $gif  # build gif file and put it in GIFS directory
           fi

           if [ $init == 1 ] ; then
             cp GIFS/$gif  $gifmov
             echo $year > ${type}-${CASE}.catalog
             init=0
           else
             gifsicle -d100 -l0 $gifmov GIFS/$gif > tmp
             \mv tmp $gifmov
             echo $year >> ${type}-${CASE}.catalog
           fi

#            if [ $year == $refyear ] ; then init=0  ; fi
          else
            echo $cgm is not already available 
          fi
          year=$(( year + 1 ))
        done
    # copy to the website ${toto:=none}
        if [ ${gifmov:=none} != none ] ; then
          copy
        fi
        gifmov=
    done
#  TO TOUCH : avoid specific machines and login in the core of the script JMM
    # if dir=CONTOURS, copy also cnt.txt file
    if [ $dir == CONTOURS ] ; then
      scp $DIAGS/../$dir/${CONFCASE}*txt drakkar@meolipc.legi.grenoble-inp.fr:DRAKKAR/$CONFIG/${CONFCASE}/${dir}/$gifmov ;
    fi
    cd ../
    else
        echo $dir does not exit, going my way forward
    fi   # if dir does'nt exist
done

dir=python

cd $dir

for type in atl_flxt atl_mxl atl_psi atl_t-s-0-200-1000 glob_eke0-ssh-t0-s0 glob_flxt glob_ice glob_mxl natl_ice natl_mxl; do

  list=$(ls *_${type}_*)
  DEBUT=$(echo $list | awk '{print $1}' | awk -F_ '{print $1}')

  gifmov=${DEBUT}_${type}.gif
  convert $list -gravity south -set delay 100 $gifmov
  copy

done
