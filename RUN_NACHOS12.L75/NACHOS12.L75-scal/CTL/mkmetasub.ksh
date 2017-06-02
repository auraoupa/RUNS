#!/bin/ksh

echo "#!/bin/ksh " > metasub.ksh
cat possible_choice2.txt | awk '{ if ( NR > 1 ) printf "%s %5d %5d %5d %5d \n", "./run_nemo_occigen2.ksh ",$1,$2,$6,$10 }' >>  metasub.ksh
chmod 755 metasub.ksh



exit

