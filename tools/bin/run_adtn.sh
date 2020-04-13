#!/bin/bash

###  
###  Run a scenario with ADTN nodes.
###  
###  usage: ./run_adtn.sh <sceanrio_name>
###     A directory scenario_name must exist under ${LEPTON_HOME}/scenario/
###       

if [ $# -ne 1 ]; then
    echo "usage: $0 <sceanrio_name>"
    exit 1
fi

# check if needed global variables are set
if [ -z $LEPTON_HOME ]; then
    echo "$0 -> Error: \$LEPTON_HOME is not defined."
	exit 1
fi
if [ -z $ADTNPLUS_ADAPTER_HOME ]; then
    echo "$0 -> Error: \$ADTNPLUS_ADAPTER_HOME is not defined."
    exit 1
fi

main_dir=${LEPTON_HOME%/*}
echo "main_dir -> ${main_dir}"

# clean output directories
rm -r ${main_dir}/output/adtn/* 2> /dev/null

# init port number management  
port_dir="/run/shm/tmp"
mkdir -p ${port_dir}
rm -f ${port_dir}/port_aux.lock
echo "40000" > ${port_dir}/port_aux # 40000 -> starting port number for adtn nodes


scenario_to_run=$1 # "levy_walk"

# if [ $# -ne 0 ]; then
#     scenario_to_run=$1
# else
#     echo " No given scenario to run (\$# = 0), Using DEFAULT scenario"    
# fi
echo "scenario_to_run -> ${scenario_to_run}"    

scenario_to_run_dir="${LEPTON_HOME}/scenario/${scenario_to_run}"
if [ ! -d $scenario_to_run_dir ]; then
    echo " Error: can't find scenario dir -> ${scenario_to_run_dir}"
    exit 2
fi

conf_file="${scenario_to_run_dir}/lepton.conf"
if [ ! -f $conf_file ]; then
    # gen confi
    
fi
echo "conf_file -> ${conf_file}" 

show=true
margin=10
dgs=${scenario_to_run_dir}/${scenario_to_run}.dgs
hist=${scenario_to_run_dir}/${scenario_to_run}.hist
css=${scenario_to_run_dir}/${scenario_to_run}.css

# start lepton with the defined configuration file
lepton.sh start \
		show=$show \
		time_margin=$margin \
		in_dgs=$dgs \
		in_hist=$hist \
		stylesheet_file=$css \
        oppnet_adapter=${ADTNPLUS_ADAPTER_HOME}/bin/adapter.sh
        
sleep 5s # 
in_aevt=${scenario_to_run_dir}/${scenario_to_run}.aevt
out_aevt=${scenario_to_run_dir}/${scenario_to_run}_out_adtn.aevt

# runnig app scenario
./util/run_app_scenario_adtn.sh $in_aevt #&

# sleep 1510s # waiting for the end of the simulation
# lepton.sh clean

# Analize adtn nodes output logs
# ./util/analyze_log_adtn.sh $in_aevt $out_aevt
