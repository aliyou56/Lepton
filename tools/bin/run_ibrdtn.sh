#!/bin/bash

###  
###  Run scenarios (mobility & application) with IBRDTN nodes.
###  
###  usage: ./run_IBRDTN.sh <sceanrio_name>
###     A directory scenario_name must exist under ${LEPTON_HOME}/scenario/
###       

script_dir=$(realpath $(dirname $0))

# Usage
if [ $# -ne 1 ]; then
    echo "usage: $0 <sceanrio_name>"
    echo "  A directory 'scenario_name' must exist under \${LEPTON_HOME}/scenario/"
    exit 1
fi

scenario=$1
scenario_dir="${LEPTON_HOME}/scenario/${scenario}"
conf_file="${scenario_dir}/lepton.conf"
echo "scenario     : ${scenario}"    
echo "scenario_dir : ${scenario_dir}"    

if [ ! -d ${scenario_dir} ]; then
    echo " Erreur : fichier introuvable scenario_dir : ${scenario_dir}"
    exit 2
fi

lepton_params=""

if [ ! -f ${conf_file} ]; then
    echo "No conf file"
    show=true
    dgs=${scenario_dir}/${scenario}.dgs
    hist=${scenario_dir}/${scenario}.hist
    time_margin=10 
    make_edges=true

    lepton_params+="in_dgs=${dgs} in_hist=${hist} time_margin=${time_margin} make_edges=${make_edges} show=${show}"
else
    echo "With conf"
    lepton_params+="conf=${conf_file}"    
fi

lepton_params+=" oppnet_adapter=${IBRDTN_ADAPTER_HOME}/bin/adapter.sh"
echo "lepton_params : $lepton_params"
echo 

# Démarage lepton avec les paramettres
lepton.sh start ${lepton_params} &

# Du délais
sleep 10s 

# Démarage du scénario applicatif
in_aevt="${scenario_dir}/${scenario}.aevt"
${script_dir}/util/run_app_scenario_ibrdtn.sh ${in_aevt} &

duration=1665 # Temps jusqu'a la fin de la simulation

output_dir="${scenario_dir}/result/ibrdtn"
[[ ! -d ${output_dir} ]] && mkdir -p ${output_dir}

# running the performance tracker
# ${script_dir}/util/performance_tracker.sh dtnd ${duration} ${output_dir} &

sleep ${duration}s # Temps du scénario
lepton.sh stop # stop Lepton

echo ""
# Analize ibrdtn nodes output logs
output_file=${output_dir}/${scenario}-out-ibrdtn.txt
${script_dir}/util/analyze_log.sh ibrdtn ${output_file}
