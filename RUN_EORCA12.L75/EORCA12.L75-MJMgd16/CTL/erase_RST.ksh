#!/bin/ksh
CONFCASE=EORCA12.L75-MJMgd16
keep_list='11 13 15 18 20 25 30 35 41'

for all in {11..41} ; do  
     flag=0; 
     for n in $keep_list ; do
        if  [ $all = $n ] ; then flag=1 ; fi 
     done
     if [ $flag = 0 ] ; then 
       echo erase $all
       if [ -d  $DDIR/${CONFCASE}-RST.$all ] ; then
         echo rm -rf $DDIR/${CONFCASE}-RST.$all
         rm -rf $DDIR/${CONFCASE}-RST.$all
       fi
     else 
       echo keep $all
     fi
done
