#!/bin/bash

script_dir=$(realpath $(dirname $0))

if [ -z ${main_dir} ]; then
    main_dir=${LEPTON_HOME}
    [[ "${LEPTON_VAR}" != "" ]] && main_dir=$(dirname $(dirname ${LEPTON_VAR}))
fi

if [ $# -ne 2 ] ; then
    echo "usage: $0 <adtn|ibrdtn> <output-file>"
    exit 1
fi

dtn=$1
output_file=$2

lepton_out_file="${main_dir}/output/lepton/lepton.out"
dtn_out_dir="${main_dir}/output/${dtn}"

if [ ! -f ${lepton_out_file} ]; then 
    echo "[analyze_log]: File not found -> ${lepton_out_file}"
    exit 1
fi
if [ ! -d ${dtn_out_dir} ]; then 
    echo "[analyze_log]: Directory not found -> ${dtn_out_dir}"
    exit 1
fi

scala ${script_dir}/libs/logAnalyzer.jar ${lepton_out_file} ${dtn_out_dir} ${dtn} ${output_file}
