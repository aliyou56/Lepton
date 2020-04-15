#!/bin/bash

###  
###  Run scenarios (mobility & application) with ADTN nodes.
###  
###  usage: ./run_adtn.sh <sceanrio_name>
###     A directory scenario_name must exist under ${LEPTON_HOME}/scenario/
###       

# usage check
if [ $# -ne 1 ]; then
    echo "usage: $0 <sceanrio_name>"
    echo "  A directory 'scenario_name' must exist under \${LEPTON_HOME}/scenario/"
    exit 1
fi

# parent directory for output
main_dir=${LEPTON_HOME}
if [[ "${LEPTON_VAR}" != "" ]]; then
    main_dir=${LEPTON_VAR}/../..
fi
# echo "main_dir        -> ${main_dir}"
# clean output 
rm -r ${main_dir}/output/adtn/* 2> /dev/null

# init port number management  
port_dir="/run/shm/tmp"
mkdir -p ${port_dir}
rm -f ${port_dir}/port_aux.lock
echo "38000" > ${port_dir}/port_aux # 38000 -> starting port number for adtn nodes


scenario=$1
scenario_dir=${LEPTON_HOME}/scenario/${scenario}
conf_file="${scenario_dir}/lepton.conf"
echo "scenario      -> ${scenario}"    
echo "scenario_dir  -> ${scenario_dir}"    

if [ ! -d $scenario_dir ]; then
    echo " Error: can't find scenario_dir -> ${scenario_dir}"
    exit 2
fi

lepton_params=""

if [ ! -f $conf_file ]; then # if the configuration file not found
    show=true
    dgs=${scenario_dir}/${scenario}.dgs
    hist=${scenario_dir}/${scenario}.hist
    time_margin=10 
    make_edges=true

    lepton_params+="in_dgs=$dgs in_hist=$hist time_margin=$time_margin make_edges=$make_edges show=$show"
else
    lepton_params+="conf=${conf_file}"    
fi

lepton_params+=" oppnet_adapter=${ADTNPLUS_ADAPTER_HOME}/bin/adapter.sh"
echo "lepton_params -> $lepton_params"
echo ""

# start lepton with the defined params
lepton.sh start $lepton_params
        
sleep 11s # 
in_aevt=${scenario_dir}/${scenario}.aevt
out_aevt=${scenario_dir}/${scenario}_out_adtn.aevt

# # runnig app scenario
./util/run_app_scenario_adtn.sh $in_aevt #&

# sleep 1510s # waiting for the end of the simulation
# lepton.sh clean

# Analize adtn nodes output logs
# ./util/analyze_log_adtn.sh $in_aevt $out_aevt
