CASE=MAA12

year1=2010
year2=2010

for year in $(seq $year1 $year1); do

  cd $SCRATCHDIR/NACHOS12.L75/NACHOS12.L75-${CASE}-MEAN/1d/$year
  mkdir -p monitoring
  cd monitoring

  for typ in EKE PSI flxT gridT gridW MXL icemod3; do

  case $typ in
    MXL|icemod3) ln -sf ../NACHOS12.L75-${CASE}_y${year}m03.1d_${typ}.nc . ; ln -sf ../NACHOS12.L75-${CASE}_y${year}m09.1d_${typ}.nc .;;
              *) ln -sf ../NACHOS12.L75-${CASE}_y${year}.1d_${typ}.nc .;;
  esac

  done

done
