#!/bin/ksh

( for f in nemo_occigen2_*.o* ; do
   jpni=$( echo $f | awk -F_ '{print $3}' )
   jpnj=$( echo $f | awk -F_ '{print $4}' )
   jpnij=$( echo ${f%.o*} | awk -F_ '{print $5}' )
   rate=$( rate.ksh -f $f -s 250 -b 1 | awk '{ print $4 }' )
   #echo $jpni $jpnj $jpnij $rate
   printf "%5d %5d %5d %7.2f \n" $jpni $jpnj $jpnij $rate
done  ) | sort -k3n



exit


jmmolines@login0.occigen: CTL $ for f in nemo_occigen2_*.o* ; do
> echo -n $f "   "
> rate.ksh -f $f -s 250 -b 1
> done
nemo_occigen2_103_95_6080.o194486    1 RATE :   151.546153179116      step/min
nemo_occigen2_108_103_6904.o194489    1 RATE :   137.813000243407      step/min
nemo_occigen2_111_103_7068.o194488    1 RATE :   134.154219102019      step/min
nemo_occigen2_114_86_6096.o194487    1 RATE :   113.397440360988      step/min
nemo_occigen2_131_113_9079.o194493    1 RATE :   151.768959324421      step/min
nemo_occigen2_140_106_9091.o194492    1 RATE :   175.831508695947      step/min
nemo_occigen2_29_516_9901.o194494    1 RATE :   107.192996306539      step/min
nemo_occigen2_29_517_9920.o194495    1 RATE :   120.032903881948      step/min
nemo_occigen2_37_43_1086.o194476    1 RATE :   22.8106565674225      step/min
nemo_occigen2_46_35_1096.o194475    1 RATE :   21.5665605483303      step/min
nemo_occigen2_480_25_7935.o194490    1 RATE :   35.8646764336361      step/min

