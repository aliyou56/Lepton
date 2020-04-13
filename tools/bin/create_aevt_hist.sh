#!/bin/bash

scenario="adhocnet" # rome_taxis levy_walk 
scenario_dir=${LEPTON_HOME}/scenario/${scenario}
dgs=${scenario_dir}/${scenario}.dgs
aevt=${scenario_dir}/${scenario}.aevt
hist=${scenario_dir}/${scenario}.hist

# generate the aevt file from the dgs file
./util/gen_aevt_from_dgs.sh ${dgs} ${hist}

# generate history file from the dgs file (via muon_tools)
./util/dgs_to_hist.sh ${dgs} ${hist}