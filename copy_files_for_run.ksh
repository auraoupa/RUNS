
CONFIG1=NACHOS12.L75
CONFIG2=NACHOS12.L75

RUN1=MAA06
RUN2=MAA08

DIR1=/home/albert7a/RUNS/RUN_$CONFIG1/${CONFIG1}-$RUN1/CTL
DIR2=/home/albert7a/RUNS/RUN_$CONFIG2/${CONFIG2}-$RUN2/CTL

cp $DIR1/includefile.ksh $DIR2/.
cp $DIR1/run_nemo_occigen.ksh $DIR2/.
cp $DIR1/namelist_ice $DIR2/.
#cp $DIR1/namelist_ice_lim3 $DIR2/.
cp $DIR1/domain_def.xml $DIR2/.
cp $DIR1/field_def.xml $DIR2/.
cp $DIR1/file_def.xml $DIR2/.
cp $DIR1/iodef.xml $DIR2/.
cp $DIR1/grid_def.xml $DIR2/.

cp $DIR1/${CONFIG1}-${RUN1}_occigen2.ksh $DIR2/${CONFIG2}-${RUN2}_occigen2.ksh
cp $DIR1/${CONFIG1}-$RUN1.db $DIR2/${CONFIG2}-$RUN2.db
cp $DIR1/namelist.${CONFIG1}-${RUN1} $DIR2/namelist.${CONFIG2}-${RUN2}

cd $DIR2

sed -i "s/$CONFIG1/$CONFIG2/g" *
sed -i "s/$RUN1/$RUN2/g" *


