#! /bin/bash

script_dir=$(realpath $(dirname $0))
base_dir=$(realpath ${script_dir}/..)
src_dir=${base_dir}/aDTNPlus

echo ""    
echo "script_dir -> ${script_dir}"
echo "base_dir   -> ${base_dir}"
echo "src_dir    -> ${src_dir}"
echo ""    

if [ ! -d ${src_dir} ]; then
    cd ${base_dir}
    git clone https://github.com/SeNDA-UAB/aDTNPlus.git
else 
    echo "Using existed src_dir -> ${src_dir}"
fi

if [ ! -d ${src_dir} ]; then 
    exit 1
fi

echo ""    
echo "Patching aDTNPlus platform"
# patch
patch_dir=${base_dir}/BundleAgent
if [[ ! -d ${patch_dir} ]]; then
    echo "Patch dir not found -> ${patch_dir}"
    exit 2
fi
yes | cp -rfvR ${patch_dir}/Node/* ${src_dir}/BundleAgent/Node/
echo ""    

echo "Compiling and installing aDTNPlus platform ..."
cd ${src_dir}
# Building and Installing
if [[ ! -d build ]]; then 
    mkdir build && cd build 
    cmake -DLEPTON=ON ..
    make DESTDIR=${HOME}/adtnPlus install
else
    cd build
    make DESTDIR=${HOME}/adtnPlus install
fi    
cd ${base_dir}

adapter_dir=${base_dir}/adtnplus-adapter
if [[ ! -d ${adapter_dir} ]]; then
    echo "Adapter dir not found -> ${adapter_dir}"
    exit 2
fi

${script_dir}/set_adtnplus_env_var.sh ${adapter_dir}
