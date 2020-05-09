#!/bin/bash

#---------------------------------------------------------------------
# aDTNPlus adapter for lepton
#     
#  Need the following variables to be set
#	  - ADTNPLUS_HOME
#	  - ADTNPLUS_ADAPTER_HOME
#	  - ADTNPLUS_CONF
#---------------------------------------------------------------------

if [ -z ${ADTNPLUS_HOME} ]; then
	echo "Error: \$ADTNPLUS_HOME is not defined."
	exit 1
fi

if [ -z ${ADTNPLUS_ADAPTER_HOME} ]; then
    echo "Error: \$ADTNPLUS_ADAPTER_HOME is not defined."
    exit 1
fi

if [ -z ${ADTNPLUS_CONF} ]; then
    echo "Error: \$ADTNPLUS_CONF is not defined."
    exit 1
fi

#---------------------------------------------------------------------
# Variables used by LEPTON
#---------------------------------------------------------------------

node_process_tag=BundleAgent # Tags identifying a node process

# OppNetAdapter class name and classpath
oppnet_adapter_classname=uab.senda.lepton.hub.AdtnPlus_Adapter
oppnet_adapter_classpath="${ADTNPLUS_ADAPTER_HOME}/libs/adtnPlus-adapter-1.0.jar"

#---------------------------------------------------------------------
# Define where to find aDTNPlus 
#---------------------------------------------------------------------
adtnd=${ADTNPLUS_HOME}/bin/BundleAgent
adtnsend=${ADTNPLUS_HOME}/bin/adtnPlus-sender
adtnrecv=${ADTNPLUS_HOME}/bin/adtnPlus-recv

#---------------------------------------------------------------------
# Variables used by aDTN nodes
#---------------------------------------------------------------------
if [ "$lepton_host" == "" ] || [ "$lepton_host" == "localhost" ] ; then
    lepton_host=127.0.0.1
fi

disc_addr=$lepton_host
disc_port=4500

node_addr=$lepton_host
list_addr=$lepton_host

log_level=6
queue_size="1M"
processor=libaDTNPlus_FirstFwkBundleProcessor.so

# neighbour_expiration_time=4
# neighbour_cleaner_time=2
# timeout=20
# process_timeout=30

# ------------------------------------------------------------
#  Load utility functions
# ------------------------------------------------------------
. ${ADTNPLUS_ADAPTER_HOME}/bin/util/adtn_functions.sh

# ------------------------------------------------------------
# Functions used by LEPTON: start_node() and stop_node() 
# ------------------------------------------------------------

start_node() {
	#
	#  Start an aDTNPlus node
	#
	#  node_id        : id of the node (required)
	#  node_start_time: time when the node should start (EPOCH in ms, OPTIONAL)
	#  node_end_time  : time when the node should stop (EPOCH in ms, OPTIONAL)
	#  node_seed      : seed to be used by that node's random generator (OPTIONAL)

	#  lepton_host    : name or address of the host that runs LEPTON
	#  lepton_hub_port: TCP port number LEPTON's hub is listening to 
    #  disc_addr      : address to use for neighbor discovery (required)
    #  disc_port      : port number to use for neighbor discovery (required)

	echo Starting node ${node_id}

	init_dirs
	init_vars

	[[ ! -d $node_dir ]] && mkdir -p $node_dir
	[[ ! -d $node_dir/Bundles ]] && mkdir -p $node_dir/Bundles
	[[ ! -d $node_dir/Delivered ]] && mkdir -p $node_dir/Delivered
	# [[ ! -d $node_dir/Codes ]] && mkdir -p $node_dir/Codes
	if [ ! -d $node_dir/Plugins ]; then
		mkdir -p $node_dir/Plugins
		# cp $ADTNPLUS_CONF/Plugins/* $node_dir/Plugins/
		cp ${ADTNPLUS_CONF}/Plugins/${processor} ${node_dir}/Plugins/
	fi
	[[ ! -d $node_dir/Trash/aggregation/reception ]] && mkdir -p $node_dir/Trash/aggregation/reception
	[[ ! -d $node_dir/Trash/aggregation/delivery ]] && mkdir -p $node_dir/Trash/aggregation/delivery
	[[ ! -d $node_dir/Trash/drop ]] && mkdir -p $node_dir/Trash/drop

	gen_conf_file
	gen_nodeState_file

    $adtnd ${conf_file} &
	echo $! > $pid_file
}

stop_node() {
	#
	#  Stop an aDTNPlus node
	#     node_id: the id of the node (required)

    echo Stopping node ${node_id}
    init_dirs

    check_running
	pid=$(cat $pid_file) 
	kill $pid >& /dev/null
	rm -f $pid_file
}

exec_on_node() {
	#  Exec command on an aDTN node
	#     node_id: the id of the node (required)
	#     $*     : command (with arguments) to be executed on that node
    # echo Executing on ${node_id}: adtn.sh $*

    node_id=${node_id} ${ADTNPLUS_ADAPTER_HOME}/bin/adtn.sh $*
}
