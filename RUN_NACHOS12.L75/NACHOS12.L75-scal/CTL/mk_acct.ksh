#!/bin/ksh

# $Id: mk_acct.ksh 60 2015-08-26 11:40:36Z bessiere6l $
# this script uses Bull sacct command to set up an accounting file holding the details of cpus used by the nemo_curie jobs

usage()  {
     echo "USAGE: $(basename $0)  [-h ] [-f] [-o outputfile] [-n] "
     echo "    Purpose : build an accounting file for nemo_curie jobs, using sacct command"
     echo "         Without option, the process is incremental, starting after the last job already"
     echo "         taken into account."
     echo "   Options : "
     echo "   [-h] : print this help message"
     echo "   [-f] : perform a full scan for all nemo_curie.ox in the current directory."
     echo "   [-n] : save the nodelist used for the jobs (default is not to save)"
     echo "   [-o outputfile ] : use outputfile instead of the default $account_file \( or ${account_file}nod \)"
     exit 0
         }

get_acct() {
    first=1
    for nemo in ${nemolist[@]} ; do 
      jobid=${nemo#${nemolog}.o} 
      if [[ $first && $full ]] ; then
        sacct --format="Jobname%12,Jobid%-10,Ncpus%-6,CPUTimeRAW%10,Elapsed%15,TotalCPU%15,UserCPU%15,systemcpu%15,submit%21,start%21,end%21,NodeList%50" -j $jobid | head -1
        first=
      fi
      sacct --format="Jobname%12,Jobid%-10,Ncpus%-6,CPUTimeRAW%10,Elapsed%15,TotalCPU%15,UserCPU%15,systemcpu%15,submit%21,start%21,end%21,NodeList%-1024" -j $jobid | grep ${nemolog}
    done
           }

get_acct_nolist() {
    first=1
    for nemo in ${nemolist[@]} ; do 
      jobid=${nemo#${nemolog}.o} 
      if [[ $first && $full ]] ; then
        sacct --format="Jobname%12,Jobid%-10,Ncpus%-6,CPUTimeRAW%10,Elapsed%15,TotalCPU%15,UserCPU%15,systemcpu%15,submit%21,start%21,end%21" -j $jobid | head -1
        first=
      fi
      sacct --format="Jobname%12,Jobid%-10,Ncpus%-6,CPUTimeRAW%10,Elapsed%15,TotalCPU%15,UserCPU%15,systemcpu%15,submit%21,start%21,end%21" -j $jobid | grep ${nemolog}
    done
           }

get_nemolist() {
    if [ $full ] ; then
      \ls -rt $nemolog.o*
    else 
      # look for last id in accounting file
      lastid=$( tail -1  $account_file | awk '{print $2}' )  
      skip=1
      for f in $nemolog.o* ; do
        if [ ! $skip ] ; then echo $f ; fi
        if [ $f = $nemolog.o$lastid ] ; then
           skip=
        fi
      done
    fi
              }
        
account_file=account.log
nemolog=nemo_occigen
full=
node=

while getopts :hfno:  opt ;  do
  case $opt in
  ( h ) usage ;;
  ( f ) full=1 ; rm -f $account_file ;;
  ( n ) node=1 ;;
  ( o ) account_file=$OPTARG ;;
  esac
done


if [ $node ] ; then 
   account_file=${account_file}nod
fi

nemolist=($(get_nemolist ))
newlog=${#nemolist[*]}

if [ $newlog != 0 ] ; then
  if [ $node ] ; then
     get_acct >> $account_file
  else
     get_acct_nolist >> $account_file
  fi
else
   lastid=$( tail -1  $account_file | awk '{print $2}' )
   echo no newlog after $nemolog.o$lastid for $account_file
fi
