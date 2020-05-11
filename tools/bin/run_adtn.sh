#!/bin/bash

###  
###  Run scenarios (mobility & application) with ADTN nodes.
###  
###  usage: ./run_adtn.sh <sceanrio_name>
###     A directory scenario_name must exist under ${LEPTON_HOME}/scenario/
###       

script_dir=$(realpath $(dirname $0))

# usage check
if [ $# -ne 1 ]; then
    echo "usage: $0 <sceanrio_name>"
    echo "  A directory 'scenario_name' must exist under \${LEPTON_HOME}/scenario/"
    exit 1
fi

# parent directory for output
main_dir=${LEPTON_HOME}
[[ "${LEPTON_VAR}" != "" ]] && main_dir=$(dirname $(dirname ${LEPTON_VAR}))
echo "[run_adtn]: main_dir     -> ${main_dir}"

# clean output 
rm -r ${main_dir}/output/lepton/* 2> /dev/null 
rm -r ${main_dir}/output/adtn/* 2> /dev/null 

# init port number management  
port_dir="/run/shm/tmp"
mkdir -p ${port_dir}
rm -f ${port_dir}/port_aux.lock
echo "40000" > ${port_dir}/port_aux # 40000 -> starting port number for adtn nodes
#####################################

scenario=$1
scenario_dir=${LEPTON_HOME}/scenario/${scenario}
conf_file="${scenario_dir}/lepton.conf"
echo "[run_adtn]: scenario     -> ${scenario}"    
echo "[run_adtn]: scenario_dir -> ${scenario_dir}"    

if [ ! -d ${scenario_dir} ]; then
    echo " Error: can't find scenario_dir -> ${scenario_dir}"
    exit 2
fi

lepton_params=""

if [ ! -f ${conf_file} ]; then # if the configuration file not found
    show=true
    dgs=${scenario_dir}/${scenario}.dgs
    hist=${scenario_dir}/${scenario}.hist
    time_margin=10 
    make_edges=true

    if [ ! -f ${dgs} ]; then
        echo " Error: dgs file not found -> ${dgs}"
        exit 2
    fi
    if [ ! -f ${hist} ]; then
        echo " Error: hist file not found -> ${dgs}"
        exit 2
    fi

    lepton_params+="in_dgs=$dgs in_hist=$hist time_margin=$time_margin make_edges=$make_edges show=$show"
else
    lepton_params+="conf=${conf_file}"    
fi

lepton_params+=" oppnet_adapter=${ADTNPLUS_ADAPTER_HOME}/bin/adapter.sh"
echo ""
echo "lepton_params -> $lepton_params"
echo ""

# start lepton with the defined params
lepton.sh start ${lepton_params} &

sleep 10s # 
# # runnig app scenario
in_aevt=${scenario_dir}/${scenario}.aevt
${script_dir}/util/run_app_scenario_adtn.sh ${in_aevt} &

duration=1665 # duration of the simulation

output_dir=${scenario_dir}/result
[[ ! -d ${output_dir} ]] && mkdir -p ${output_dir}

# running the performance tracker
# ${script_dir}/util/performance_tracker.sh BundleAgent ${duration} ${output_dir} &

sleep ${duration}s # waiting for the end of the simulation
lepton.sh stop # stop Lepton

echo ""
# Analize adtn nodes output logs
output_file=${output_dir}/${scenario}-out-adtn.txt
${script_dir}/util/analyze_log_adtn.sh ${output_file}
