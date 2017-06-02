#!/bin/ksh
# This script is used to produce a template for a Journal suitable for wiki editing
# it must be run where nemo_jade.oxxxx files are, ie in the CTL dir of the OCNFCASE
#------------------------------------------------------------
#  $Rev: 762 $
#  $Date: 2015-02-26 09:35:35 +0100 (Thu, 26 Feb 2015) $
#  $Id: mkjournal.ksh 762 2015-02-26 08:35:35Z molines $
#--------------------------------------------------------------

usage() {
     echo USAGE: $(basename $0 ) [-h ] [-f ] [-c confcase ] [-n name ] [-u user] [-o fileout]
     echo "      -h : help "
     echo "      -f : force : do not check that you are in a CTL dir "
     echo "      -n name : use name instead of nemo_occigen"
     echo "      -c confcase : use confcase instead of CONFCASE deduced from CTL"
     echo "                  : this is usefull with option -f "
     echo "      -u user [default is $USER ]"
     echo "      -o output file [ default is journal.wiki "
     echo "      This script must be run in CTL directory"
     exit 0
        }

name=nemo_occigen
force=''
CONFCASE=''
user=$USER
filout=journal.wiki
MACHINE=$(hostname)
case $MACHINE in
( curie*   ) ; MACHINE=curie ;;
( occigen* ) ; MACHINE=occigen ;;
( ada*     ) ; MACHINE=ada  ;;
( login*occigen) ; MACHINE=occigen2 ;;
esac
name=nemo_$MACHINE


while getopts :hfn:c:u:o: opt ; do
   case $opt in 
     (h) usage ;;
     (f) force=1 ;;
     (n) name=${OPTARG} ;;
     (c) CONFCASE=${OPTARG} ;;
     (u) user=${OPTARG} ;;
     (o) filout=${OPTARG} ;;
     (*) usage ;;
   esac
done


tmp=$(pwd) 

echo $CONFCASE
echo $user
echo $filout
echo $name

# check the positioning of environment
if [ ! $DDDIR ] ; then
  if [ ! $CDIR ] ; then
    echo Environment variable CDIR and/or DDIR  must be set !
    exit 0
  else
    DDIR=${DDIR:-$CDIR}
  fi
fi


if [ ! $force ] ; then
  if [ $(basename $tmp) != CTL ] ; then
     echo ERROR: you must be in a CTL directory to run $(basename $0 )
     usage
  else
    tmp=${tmp%/CTL} ; CONFCASE=$( basename $tmp)
  fi
else
  if [ ! $CONFCASE ] ; then
    echo 'you must specify confcase with -c in case of force option (-f ) '
    usage
  fi
fi

CONFIG=$( echo $CONFCASE | awk -F- '{print $1}' )
if [ -d $DDIR/${CONFIG}/${CONFCASE}-S/ANNEX ] ; then
   SWDIR=$DDIR/${CONFIG}/${CONFCASE}-S/ANNEX
else
   SWDIR=$DDIR/${CONFIG}/${CONFCASE}-S
fi
if [ $user != $USER ] ; then 
   # infer SWDIR for user ... assume the same location but on user account
   SWDIR=$( echo $SWDIR | sed -e "s;$USER;$user;g" )
fi

LookInNamelist()    { eval grep -e $1 $SWDIR/namelist_oce.$nn_no     | sed -e 's/=/  = /' | awk ' {if ( $1 == str ) print $3 }' str=$1 ; }

LookInOcean()    { eval grep -e $1 $ocean     | awk ' { pos=NF-1 ; print $pos }' ; }

wikiheader()  {  \
cat << eof > $filout
{{{
#!rst

**$CONFCASE** Journal of the runs performed on $MACHINE

.. list-table::
   :widths: 6 10 10 6 12 6 6 6 6 6 6 6 12 40
   :header-rows: 1


   * - **no**
     - **nit000**
     - **nitend**
     - **end**
     - **Date**
     - **NPROC**
     - **jobid**
     - **CPU(h)**
     - **rdt**
     - **aht0**
     - **bhm0**
     - **traadv**
     - **dynadv**
     - **comments**

eof

echo   ; } 

wikiformat()  {  \
      nbproc=$(printf "%d" $nbproc)
cat << eof >> $filout

   * - $nn_no
     - $nit000
     - $nitend
     - $ndastp
     - $fecha
     - $nbproc
     - $jobid
     - ${jobid}_CPU
     - ${rdt%.}
     - ${aht0}
     - $bhm0
     - $traadv
     - $dynadv
     - $error
eof

echo   ; }

wikiclose() { cat << eof >> $filout
}}}
eof

    echo     ; }


 wikiheader
for g in  $(ls -t $name.e* | head -45)  ; do
  jobid=${g#$name.e}
  f=$name.o$jobid
  # seg  ends ok ?
  ocean=$(grep ocean.output $name.e$jobid | grep ABORT | grep mv | awk '{print $NF}' )
  ocean=${ocean:='OK'}

#  nbproc=$( cat $g | grep NB_NPROC | awk '{ print $5}' ) 
  nbproc=$( cat $g  | grep -w NB_NPROC | awk -F= '{print $NF}' | tail -1 )
  nn_no=$( cat $g | grep '++ no=' | head -1 | awk -F= '{print $2}'  )
  rdt=$( cat $g   | grep rdt= | head -1 | awk -F= '{print $2}'  )
  nit000=$( cat $g | grep nit000 | head -1 | awk -F= '{print $2}'  )
  nitend=$( cat $g | grep -w nitend | grep -v nitend.txt | head -1 | awk -F= '{print $2}'  )
  ndastp=$( cat $g | grep aammdd | head -1 | awk -F= '{print $2}'  )
  ndastp=${ndastp:=''}

  if [ $ocean = 'OK' ] ; then
    ztmp=$(LookInNamelist ln_dynadv_vec) ; if [ $ztmp = .true. ] ; then dynadv=VEC ; fi
    ztmp=$(LookInNamelist ln_dynadv_ubs) ; if [ $ztmp = .true. ] ; then dynadv=UBS ; fi

    ztmp=$(LookInNamelist ln_traadv_fct) ; if [ $ztmp = .true. ] ; then traadv=FCT ; fi
    if [ $traadv = FCT ] ; then traadv=${traadv}$(LookInNamelist nn_fct_h)$(LookInNamelist nn_fct_v) ; fi
    ztmp=$(LookInNamelist ln_traadv_ubs) ; if [ $ztmp = .true. ] ; then traadv=UBS ; fi
    if [ $(LookInNamelist ln_dynldf_blp) = .true. ] ; then 
      bhm0=$(LookInNamelist rn_bhm_0 )
    else
      bhm0=NotUsed
    fi
    aht0=$(LookInNamelist rn_aht_0 )
    error='no error '
    nn_no='**'$nn_no'**'
  else 
    if [ -f  $ocean ] ; then
     bhm0=$(printf "%6.1e" $(LookInOcean rn_ahm_0_blp $ocean))
     aht0=$(printf "%6.1e" $(LookInOcean rn_aht_0_lap $ocean))
    else
     bhm0=''
     aht0=''
    fi
#   error=$( grep -m 1 -A3 mpiexec $g | tail -3 )
    error=$( grep -A 6 'E R R' -m 1 $ocean | tail -4 | head -3 | tr -d '\012' )
    nitend='**'$( grep -B 2 'Post processing of the run' $f | head -1 | awk '{ print $1}' )'**'
    ndastp='**'$( grep 'run stop at' $ocean | awk '{ print $NF}' )'**'
  fi
  
   nit000=${nit000:=''}
   nitend=${nitend:=''}
   rdt=${rdt:=''}
   bhm0=${bhm0:=''}
   fecha=$(ls -l --time-style=long-iso $g | awk '{print $6 " " $7}' )
#  echo  $nn_no $nit000 $nitend $ndastp $fecha $jobid $nbproc $rdt $ahm0 
#  echo $error
  wikiformat 
  unset nit000 nitend ndastp rdt ahm0 error
done

wikiclose



