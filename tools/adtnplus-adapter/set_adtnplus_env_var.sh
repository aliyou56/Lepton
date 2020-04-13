
echo Setting aDTNPlus environment variables ...

ret=$(cat ~/.$(basename $SHELL)rc | grep ADTNPLUS | wc -l)

if [ $ret -ne 0 ] ; then
    echo aDTNPlus environment variables are already set.
    return 0
fi

if [ adapter_dir == "" ] ; then
    adapter_dir=$(realpath $(dirname $0))
fi
echo adapter_home=$adapter_dir 

cat << EOF >> ~/.$(basename $SHELL)rc
#
# aDTNPlus environment variables
export ADTNPLUS_HOME="/home/${USER}/adtnPlus/usr/local"
export ADTNPLUS_CONF="/home/${USER}/adtnPlus/var/lib/adtnPlus" 
export ADTNPLUS_ADAPTER_HOME="${adapter_dir}"
export PATH="\${PATH}:\${ADTNPLUS_HOME}/bin"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${ADTNPLUS_HOME}/lib"
#
EOF
source ~/.$(basename $SHELL)rc

echo aDTNPlus environment variables set.
