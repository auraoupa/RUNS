#!/bin/ksh

echo "#!/bin/ksh " > metasub.ksh
cat possible_choice.txt | awk '{ if ( NR > 1 ) printf "%s %5d %5d %5d %5d \n", "./run_nemo_occigen2.ksh ",$1,$2,$6,$13 }' >>  metasub.ksh
chmod 755 metasub.ksh



exit

  1    2   3   4        5      6      7     8         9        10     11      12      13     14                                                 
  46   35  96 105     10080   1096   514 0.70886    45.67      104    50    39.14     136    44
  37   43 119  86     10234   1086   505 0.71312    45.25      114    50    38.79     118    43
  60   51  74  73      5402   2012  1048 0.69738    83.83      100    88    71.86     116    76
