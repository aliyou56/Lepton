#!/bin/bash

###
###  This script allows to run an application scenario using ADTN nodes.
###  It reads the event file and executes the command read.
###
###    usage: ./run_app_scenario <aevt_file>
###

# usage check
if [ $# -lt 1 ] ; then
    echo "usage: $0 <aevt_file>"
    exit 1
fi 

aevt_file=$1
if [ ! -f $aevt_file ] ; then
    echo " $0 -> error: aevt_file not found -> $aevt_file"
    exit 2
fi  

echo ""
echo "** Running application scenario **"

start_time=$(echo "scale=0; $(date +%s.%N) * 1000" | bc | cut -d. -f1)
echo $start_time

grep " snd " $aevt_file | while read time action sdr dst mid ; do
    mid=$(echo $mid | cut -d= -f2)
    dst=$(echo $dst | cut -d= -f2)
    abs_time=$(($start_time + $time))
    now=$(echo "scale=0; $(date +%s.%N) * 1000" | bc | cut -d. -f1)
    wait=$(($abs_time - $now))
    if [ $wait -gt 0 ] ; then
        wait=$(echo "scale=3; $wait / 1000" | bc)
        echo ""
        echo "Waiting until $time ($wait sec.)"
        sleep $wait
    fi
    echo lepton.sh exec $sdr send $dst $mid
    lepton.sh exec $sdr send $dst $mid
done
