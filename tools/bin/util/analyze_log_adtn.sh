#!/bin/bash

if [ -z main_dir ]; then
    main_dir={LEPTON_HOME%/*}
fi

lepton_out_file=${main_dir}/output/lepton/lepton.out
adtn_out_dir=${main_dir}/output/adtn
# $1 -> in_aevt
# $2 -> out_aevt
scala ./util/libs/adtnLogAnalyzer.jar ${lepton_out_file} ${adtn_out_dir} $1 $2 