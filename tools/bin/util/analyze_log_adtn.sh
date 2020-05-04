#!/bin/bash

script_dir=$(realpath $(dirname $0))

if [ -z ${main_dir} ]; then
    main_dir={LEPTON_HOME}
    if [[ "${LEPTON_VAR}" != "" ]]; then
        current_dir=$(pwd)
        cd ${LEPTON_VAR}/../.. 
        main_dir=$(pwd)
        cd $current_dir
    fi
fi

if [ $# -ne 1 ] ; then
    echo "usage: $0 <output-file>"
    exit 1
fi

lepton_out_file=${main_dir}/output/lepton/lepton.out
adtn_out_dir=${main_dir}/output/adtn

if [ ! -f ${lepton_out_file} ]; then 
    echo "[analyze_log_adtn]: File not found -> ${lepton_out_file}"
    exit 1
fi
if [ ! -d ${adtn_out_dir} ]; then 
    echo "[analyze_log_adtn]: Directory not found -> ${adtn_out_dir}"
    exit 1
fi

scala ${script_dir}/libs/logAnalyzer.jar ${lepton_out_file} ${adtn_out_dir} adtn $1