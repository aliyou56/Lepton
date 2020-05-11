#! /bin/bash

if [ $# -ne 1 ] ; then
    echo "usage: $0 <adapter_home>"
    exit 1
fi
adapter_home=$1
echo "adapter_home -> ${adapter_home}"

echo Setting aDTNPlus environment variables ...

ret=$(cat ~/.$(basename $SHELL)rc | grep ADTNPLUS | wc -l)

if [ $ret -ne 0 ] ; then
    echo aDTNPlus environment variables are already set.
    exit 2
fi

if [ ! -d ${adapter_home} ]; then 
    echo "Can't find adapter_home -> ${adapter_home}"
    exit 3
fi

cat << EOF >> ~/.$(basename $SHELL)rc
#
# aDTNPlus environment variables
export ADTNPLUS_HOME="${HOME}/adtnPlus/usr/local"
export ADTNPLUS_CONF="${HOME}/adtnPlus/var/lib/adtnPlus" 
export ADTNPLUS_ADAPTER_HOME="${adapter_home}"
export PATH="\${PATH}:\${ADTNPLUS_HOME}/bin"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${ADTNPLUS_HOME}/lib"
#
EOF
source ~/.$(basename $SHELL)rc

echo aDTNPlus environment variables set.
