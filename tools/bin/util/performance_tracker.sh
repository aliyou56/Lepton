#!/bin/bash

# This script allows to track cpu and memory usage of a DTN system (ADTN or IBRDTN)
# when running. It writes in the output file values read from 'ps' command every 
# second until the given duration
#
#  Required params:
#     tag_name        : used to track wanted process with the 'grep' command
#     duration        : the duration of the tracking
#     performance_dir : the output directory
#
#  output
#     a file which conatains
#       x=value
#       pid cpu(%) mem(%) command

script_dir=$(realpath $(dirname $0))

if [ $# -ne 3 ]; then 
    echo "usage: $0 <tag_name> <duration> <performance_dir>"
    exit 1
fi

tag_name=$1
duration=$2
performance_dir=$3
out_file=${performance_dir}/performance.txt

# creat the directory if not exist
[[ ! -d ${performance_dir} ]] &&  mkdir -p ${performance_dir}

echo "[performance]: starting -> tag_name=$tag_name duration=$duration performance_dir=$performance_dir"

for i in `seq 1 $duration`;
do
	sleep 1
    echo x=$i >> ${out_file}
    ps o pid,%cpu,%mem,command ax | grep ${tag_name} | while read psLine; do
        # take into account only ADTN nodes process
        [[ $psLine == *"/bin/BundleAgent"* ]] && echo $psLine >> ${out_file}
    done
done

cleaned_file=${performance_dir}/cleaned-performance.txt
scala ${script_dir}/libs/performanceDataCleaner.jar ${out_file} ${cleaned_file}

python3 ${script_dir}/plot_perf_data.py ${cleaned_file}