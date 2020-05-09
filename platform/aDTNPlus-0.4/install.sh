#! /bin/bash

# This script compiles and installs aDTNPlus into the user directory
# Use the following command: cmake, make

#  Initialize the base directory
script_dir=$(realpath $(dirname $0))

echo "Compiling and installing aDTNPlus platform ..."
echo "script_dir -> ${script_dir}"

# Building and Installing
mkdir build && cd build
cmake -DLEPTON=ON ..
make DESTDIR=/home/${USER}/adtnPlus install

adapter_dir=${script_dir}/../aDTNPlus-adapter
. ${adapter_dir}/set_adtnplus_env_var.sh
