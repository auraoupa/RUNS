#!/bin/ksh

for f in nemo_occigen2_*.o* ; do proc=$(echo $f | awk -F_ '{print $5}' | awk -F. '{print $1}'); echo -n $proc "   "; rate_light.ksh -f $f -s 250 -b 1 ; done > results.txt
for f in nemo_occigen2_*.o* ; do proc=$(echo $f | awk -F_ '{print $5}' | awk -F. '{print $1}'); echo -n $proc "   "; rate2.ksh -f $f -s 250 -b 1 ; done > results_tronc2.txt
