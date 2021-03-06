#!/bin/ksh
#        make_ncdf_timeseries.ksh
#   This script is used to concatenate yearly monitoring files to multi'
#   years files, ready for time-series plotting. It is mandatory to pass'
#   the CONFIG and CASE to this script either with -a or -C option. '
#   Command line option superseed default options.'

#--------------------------------------------------------------
#   $Rev: 439 $
#   $Date: 2012-04-13 20:45:17 +0200 (Fri, 13 Apr 2012) $
#   $Id: make_ncdf_timeseries.ksh 439 2012-04-13 18:45:17Z dussin $
#--------------------------------------------------------------
# give usage of the script
usage ()          {
          echo '   '
          echo "USAGE: $(basename $0)  [-a | -C CONFIG CASE]  [ -h ] ..."
          echo '        ... [-d diag_dir] [-m monitor_dir] [-y start_year]'
          echo '        ... [-f output_frequency] [-c calendar] [-M machine] [-l]'
          echo '   '
          echo '  PURPOSE: '
          echo '       This script is used to concatenate yearly monitoring files to multi'
          echo '       years files, ready for time-series plotting. It is mandatory to pass'
          echo '       the CONFIG and CASE to this script either with -a or -C option. '
          echo '       Command line option superseed default options.'
          echo '   '
          echo '  MANDATORY ARGUMENTS: one of ... '
          echo '   -a             : take CONFIG and CASE from the actual directory.'
          echo '                   (Requires  to launch the script from CTL/CDF dir.'
          echo '   -C CONFIG CASE : specify CONFIG and CASE name ( 2 separate words).'
          echo '   '
          echo '  OPTIONS: '
          echo '   -h             : print this message.'
          echo '   -d diag_dir    : specify the full path of -DIAGS directory to use.'
          echo '   -m monitor_dir : specify the full path of -MONITOR directory to use.'
          echo '   -y start_year  : specify the starting year of the CONFIG-CASE experiment.'
          echo '   -f output_freq : specify the output frequency in days'
          echo '   -c calendar    : specify the calendar type ( one of : gregorian, noleap, 360d )'
          echo '   -M machine     : indicate the name of the target machine (see option -l) '
          echo '                    for already regognized machines).'
          echo '   -l             : list available pre-defined machines'
          echo '   '
                  }
# retrieve config and case from directory name
look_for_config() {
       dirup=$( dirname $(pwd) )
       if [ $(basename $dirup ) != 'CTL' ] ; then 
         echo ' E R R O R !'
         echo '   -a option can be used only in CTL/CDF directory'
         echo '   Move to there or use -C option.'
         echo ' '
         usage ; exit 1
       else
         CONFCASE=$( basename $( dirname $dirup ) )
         CONFIG=${CONFCASE%-*}
         CASE=${CONFCASE#*-}
       fi
                  }
# check existence of directory
chkdir()          {
       if [ ! -d $1 ] ; then mkdir $1 ; fi
                  }

# open tunnel through meolkerg for machine without direct acces to meolipc
open_tunnel() {
      case $MACHINE in
      ( curie000 )
      # obsolete ( ==> curie000 is a dummy  name ) meolipc is now directly accessible from curie
      ssh_port="-p 3022"
      scp_port="-P 3022" 
      web_host=localhost 

      # check if tunnel already open
      pid=$(ps -edf | grep "ssh -f -N -L 3022:meolipc.legi.grenoble-inp.fr:22" | grep -v grep | head -1 | awk '{ print $2}')
      if [  $pid ] ; then
         exit
      else
         ssh -f -N -L 3022:meolipc.legi.grenoble-inp.fr:22 meolkerg.legi.grenoble-inp.fr
      fi  ;;

      ( * ) 
      ssh_port=
      scp_port=  
      web_host=meolipc.legi.grenoble-inp.fr  ;;
      esac
              }

# close tunnel
close_tunnel() {
    pid=$(ps -edf | grep "ssh -f -N -L 3022:meolipc.legi.grenoble-inp.fr:22" | grep -v grep | head -1 | awk '{ print $2}')
    if [ $pid ] ; then  kill -9 $pid ; fi
               }

# copy_nc_to_web : copy the time series in netcdf to the DRAKKAR website
# usage : copy_nc_to_web file
copy_nc_to_web()  {
          ssh $ssh_port $web_host -l drakkar \
         " if [ ! -d DRAKKAR/$CONFIG/$CONFCASE/DATA ] ; then mkdir -p DRAKKAR/$CONFIG/$CONFCASE/DATA ; fi "
          scp $scp_port $@ drakkar@${web_host}:DRAKKAR/$CONFIG/${CONFCASE}/DATA/ 
                  }

#################################################
###   script starts here                      ###
#################################################
# Start initialization

if [ $# == 0 ] ; then
    usage ; exit 0
    exit 0
fi

 # browse command line
 args=("$@")  # save argument list for further use
 while  getopts :haC:d:m:y:M:lf:c: opt ; do
   case $opt in 
      (h) usage ; exit 0  ;;
      (a) look_for_config ;;
      (C) CONFIG=${OPTARG}  ; i=$(( OPTIND - 1 )) ;
          CASE=${args[$i]}  ; (( OPTIND++ )) 
          CONFCASE=${CONFIG}-${CASE} ;;
      (d) DIAGS=${OPTARG} ;;
      (m) MONITOR=${OPTARG} ;;
      (y) yearbeg=${OPTARG} ;;
      (f) freqinday=${OPTARG}   ;;
      (c) calendar=${OPTARG}   ;;
      (M) MACHINE=${OPTARG} ;;
      (l) echo ' Defaults configuration exists for the following pre-defined machines:' ;
          for m in  ada jade occigen occigen2 curie meolkerg ; do 
            echo '    - ' $m
          done ;
          exit 0 ;;
      (\?) echo "Invalid option: -$OPTARG " ; usage; exit 1 ;;
      (:)  echo "Missing argument for option -$OPTARG " ; usage; exit 1 ;;
   esac
 done

 if [ ! $CONFIG ] ; then
   echo E R R O R : mandatory argument missing ! ; usage ; exit 1
 fi

## MACHINE can  be defined in your .profile 
if [ $MACHINE ] ; then
  echo '>>> Your machine is defined and is' $MACHINE
else
  MACHINE=`hostname`
  echo '>>> Your machine is not defined, please do it in your .profile (or .cshrc, .bashrc, ...)'
  echo '>>>  or use the -M option, if automatic guess fails ...'
  echo '>>> I am trying to guess its name...'
  echo '>>> found : '$MACHINE
fi

ierr=0  # reset error flag
case $MACHINE in 
  ( jade     ) rootdir=/scratch/$USER         ;;
  ( occigen  ) rootdir=$WORKDIR               ;;
  ( occigen2 ) rootdir=$WORKDIR               ;;
  ( ada      ) rootdir=$WORKDIR               ;;
  ( curie    ) rootdir=$DDIR                  ;;
  ( meolkerg ) rootdir=$ISLANDSPATH_MODEL_SET ;;
  ( *        ) echo " Machine $MACHINE is not pre-defined ";
               if [ $DIAGS ] ; then echo "using DIAGS from command line " ;
                               else (( ierr++ )) ;
                               fi ;
               if [ $MONITOR ] ; then echo "using MONITOR from command line " ;
                               else (( ierr++ )) ;
                               fi ;;
esac

if [ $ierr != 0 ] ; then 
  echo '>>>  E R R O R : DIAGS or MONITOR cannot be inferred.' 
   usage  ; exit 1
fi

# set DIAGS and MONITOR from MACHINE name if necessary
if [ ! $DIAGS   ] ; then DIAGS=$rootdir/$CONFIG/$CONFCASE-DIAGS/NC ; fi
if [ ! $MONITOR ] ; then MONITOR=$rootdir/$CONFIG/$CONFCASE-MONITOR ; fi

# Security tests
PARENT_DIR=$(dirname $MONITOR )
chkdir $PARENT_DIR
chkdir $MONITOR

# End initialization

#####################################################################################
### This is where the real stuff begins                                           ###
#####################################################################################
# Additional function ...

ask_yearbeg()   {
   echo '-------------------------------------------------------'
   echo '>>> The Starting date of the run is not set properly'
   echo '>>> DMONTOOLS will help you fixing this issue'

   echo '>> What is the first year of the run (ex: 1958) ?'
   read yearbeg
   yearbeg=$( printf "%04d" $yearbeg )
   (( iask++ ))
                }
ask_freqinday() {

   echo '>> What is the output frequency of the model (in days, usually 5) ?'

   read freqinday
   (( iask++ ))
                }

ask_calendar()  {

   echo '>> What is the type of calendar for this run ( gregorian (leap), noleap, 360d ?)'

   read calendar
   (( iask++ ))
                }

chkanswer()     {

   echo ''
   echo 'Please verify...'
   echo 'Run starts the 1st of January' $yearbeg
   echo 'Model outputs are every' $freqinday 'days'
   echo "Calendar is  $calendar "
   echo 'are you OK with that ? (y/n)'

   good_ans=0

   while [ $good_ans == 0 ]  ; do

      read answer
      answer=$( echo $answer | tr [a-z] [A-Z] )

      case $answer in 
      ( Y ) echo '>> Correcting time counter !' ; good_ans=1 ;;
      ( N ) echo '>> Oh ! Too bad... you have to run this program again' ; good_ans=1 ; 
            echo '>> You might think of using line options (-y -f -c )' ; usage  ;
            exit 1 ;;
      ( * ) echo '>> sorry ?!' ; good_ans=0 ;;
      esac
   done
                }

cp $DMON_ROOTDIR/MONITOR_PROD/drakkar_sections_table.txt $MONITOR
cp $DMON_ROOTDIR/MONITOR_PROD/drakkar_trpsig_table.txt   $MONITOR

#------------------------------------------------------------------
# Concatenation of DIAGS

cd $DIAGS
# list of all diags available in DIAGS dir : eg : 1y_MAXMOC.nc, 1m_MAXMOC.nc ...
LIST_OF_DIAGS=$( ls -1 ${CONFCASE}*  | awk -F_ '{ printf "%s_%s\n",$3,$4 }' | sort -u )

# look for xios format ?
sample_file=$(ls -1 ${CONFCASE}*nc | head -1 )
ztag=$( echo $sample_file | awk -F_ '{print $2}' )
xios=${ztag#y????}

## 
for diagtyp in $LIST_OF_DIAGS ; do
    ncrcat -F -O -h ${CONFCASE}_y????${xios}_${diagtyp} -o $MONITOR/${CONFCASE}_${diagtyp}
done

# Levitus are just ready !
cp LEVITUS*nc $MONITOR

#------------------------------------------------------------------
# Time counter correction (if needed)

cd $MONITOR

for file in ${CONFCASE}*.nc ; do
  ndate0=$(ncdump -h $file | grep -i start_date | tail -1 | awk '{print $3}')
  ndate0=${ndate0:=-1}  # if not set or set to -1, file requires treatment
  if [ $ndate0 == -1 ] ; then
     iask=0
     if [ ! $yearbeg   ] ; then ask_yearbeg   ; fi
     if [ ! $freqinday ] ; then ask_freqinday ; fi
     if [ ! $calendar  ] ; then ask_calendar  ; fi
     if [ $iask != 0   ] ; then chkanswer     ; fi
     yearbeg=$( printf "%04d" $yearbeg )
     secshift=$( echo $freqinday | awk '{ print $1/2.*86400 }' )
     # transform yearbeg/01/01 in timestamp in seconds
     sec0=$( echo $yearbeg | awk '{ cmd=$1" 01 01 00 00 00"; print mktime ( cmd ) }' )
     # shift secshfit backward
     sec=$(( sec0 - secshift ))
     time_units="seconds since $(echo $sec | awk '{ print strftime ("%C%y-%m-%d %H:%M:%S",$1) }' )"
     time_origin=$( echo $sec | awk '{ print strftime ("%C%y-%b-%d %H:%M:%S",$1) }' | tr [a-z] [A-Z] )
     # modify time_counter attribute
     ncatted -a calendar,time_counter,m,c,"$calendar" $file
     ncatted -a units,time_counter,m,c,"$time_units" $file
     ncatted -a time_origin,time_counter,m,c,"$time_origin" $file
  fi
  if [ $xios ] ; then 
  # Correct time_origin for python stuff [ with XIOS time_origin is like 1958-01-01 00-00-00 and python expects 1958-JAN-01 00-00-00 ]
  to=$(ncdump -h  $file| grep time_origin| awk -F= '{print $2}'| sed -e 's/;//' )
  mm=$(echo  $to | awk -F- '{print $2}')

  case $mm in
 (01)  mon=JAN ;;
 (02)  mon=FEB ;;
 (03)  mon=MAR ;;
 (04)  mon=APR ;;
 (05)  mon=MAY ;;
 (06)  mon=JUN ;;
 (07)  mon=JUL ;;
 (08)  mon=AUG ;;
 (09)  mon=SEP ;;
 (10)  mon=OCT ;;
 (11)  mon=NOV ;;
 (12)  mon=DEC ;;
  esac

  new_to=$(echo $to |sed -e "s/\"//g" | sed -e "s/-${mm}-/-${mon}-/ " )
  ncatted -h -a time_origin,time_counter,m,c,"$new_to" $file
  fi
done

### end of concat and merge of netcdf files
#------------------------------------------------------------------
### Utilities : copy to the DRAKKAR website

cd $MONITOR

open_tunnel
copy_nc_to_web *.nc
close_tunnel



