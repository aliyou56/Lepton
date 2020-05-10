#!/bin/bash

###  
###  Run scenarios (mobility & application) with IBRDTN nodes.
###  
###  usage: ./run_IBRDTN.sh <sceanrio_name>
###     A directory scenario_name must exist under ${LEPTON_HOME}/scenario/
###       


# Usage
if [ $# -ne 1 ]; then
    echo "usage: $0 <sceanrio_name>"
    echo "  A directory 'scenario_name' must exist under \${LEPTON_HOME}/scenario/"
    exit 1
fi

# Répertoire des résultats
if [ ! -d "${LEPTON_HOME}/result" ]; then
    mkdir "${LEPTON_HOME}/result"
fi


scenario=$1
scenario_dir=${LEPTON_HOME}/scenario/${scenario}
conf_file="${scenario_dir}/lepton.conf"
echo "scenario     : ${scenario}"    
echo "scenario_dir : ${scenario_dir}"    

if [ ! -d $scenario_dir ]; then
    echo " Erreur : fichier introuvable scenario_dir : ${scenario_dir}"
    exit 2
fi

lepton_params=""

if [ ! -f $conf_file ]; then
    echo "No conf file"
    show=true
    dgs=${scenario_dir}/${scenario}.dgs
    hist=${scenario_dir}/${scenario}.hist
    time_margin=10 
    make_edges=true

    lepton_params+="in_dgs=$dgs in_hist=$hist time_margin=$time_margin make_edges=$make_edges show=$show"
else
    echo "With conf"
    lepton_params+="conf=${conf_file}"    
fi



#lepton_params+=" oppnet_adapter=${IBRDTN_ADAPTER_HOME}/bin/adapter.sh"
echo "lepton_params : $lepton_params"
echo 

# Démarage lepton avec les paramettres
lepton.sh start $lepton_params &

# Du délais
sleep 11s

# Démarage du scénario applicatif
#cd ${LEPTON_HOME}/util/
irbdtn_scenario_params=${scenario_dir}/${scenario}.aevt
echo "irbdtn scenario params : $irbdtn_scenario_params"

${LEPTON_HOME}/util/run_scenario_ibrdtn.sh $irbdtn_scenario_params &
echo
echo "${LEPTON_HOME}/util/run_scenario_ibrdtn.sh $irbdtn_scenario_params &"
echo 
# Temps jusqu'a la fin de la simulation

duration=1665 

#Performance
if [ ! -d "$LEPTON_HOME/perf" ];
then
    mkdir "$LEPTON_HOME/perf"
fi

#$LEPTON_HOME/util/performance_tracker.sh dtnd ${duration} $LEPTON_HOME/perf &

#Temps du scénario
sleep ${duration}s

lepton.sh clean
echo "lepton : clean"

# Copie des résultats dans ${LEPTON_HOME}/result
folderOut="/dev/shm/$USER/lepton/"
folderOutResult="${LEPTON_HOME}/result/$1"
mkdir "${LEPTON_HOME}/result/$1"
#cp -r $folderOut $folderOutResult
folderOutirbdtn="/dev/shm/$USER/ibrdtn/"
cp -r $folderOutirbdtn $folderOutResult
mv $folderOutResult "${LEPTON_HOME}/result/$(date)_$1"
for i in ls -p | grep -v /
do
    echo $i
done





exit 0