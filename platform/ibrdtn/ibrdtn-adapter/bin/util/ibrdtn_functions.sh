#!/bin/bash

if [ -z $IBRDTN_HOME ]; then
    echo "Error: \$IBRDTN_HOME is not defined."
    exit
fi

# ------------------------------------------------------------
# Define where to find IBRDTN code
dtnd=${IBRDTN_HOME}/sbin/dtnd 
dtnsend=${IBRDTN_HOME}/bin/dtnsend
dtnrecv=${IBRDTN_HOME}/bin/dtnrecv

# ------------------------------------------------------------
# Variables used by IBRDTN nodes

if [ -z $itf ] ; then
    itf=$(ip link  | grep -v -E "loopback|LOOPBACK" | head -1 | cut -d" " -f 2 | cut -d: -f1)
fi

if [ -z $disc_addr ] ;  then
    disc_addr=224.0.0.142
    disc_port=4551
fi

# ------------------------------------------------------------
init() {

    # ibrdtn_log_dir=/run/shm/${USER}/ibrdtn
	dir=${LEPTON_HOME} 
    [[ "${LEPTON_VAR}" != "" ]] && dir=$(dirname $(dirname ${LEPTON_VAR}))
    base_dir=${dir}/output/ibrdtn
    node_dir=${base_dir}/${node_id}
    pid_file=${node_dir}/pid
    conf_file=${node_dir}/conf
    socket_file=${node_dir}/socket
}

# ------------------------------------------------------------
gen_conf_file() {
    # 
    # Generates a configuration file for an IBRDTN node
    #
    #  Uses the following variables:
    #
    # node_id   : id of the node (required)
    # node_dir  : directory for the logs produced by that node (required)
    # itf       : interface the IBRDTN node should bind to (required)
    # disc_addr : address to use for neighbor discovery (required)
    # disc_port : port number to use for neighbor discovery (required)
    # disc_lport: local port number to use for neighbor discovery (OPTIONAL)
    
    cat <<EOF | sed -e s%NODE_ID%${node_id}%g \
		    -e s%NODE_DIR%${node_dir}%g \
		    -e s%ITF%${itf}%g \
		    -e s%DISC_ADDR%${disc_addr}%g \
		    -e s%DISC_PORT%${disc_port}%g \
		    -e s%DISC_PERIOD%${hub_period}%g \
		    > ${conf_file}
local_uri = dtn://NODE_ID
logfile = NODE_DIR/log
api_socket = NODE_DIR/socket
net_interfaces = lan0
net_lan0_type = tcp
#net_lan0_interface = ITF
net_lan0_interface = any
net_lan0_port = 0

routing = epidemic
dht_enabled = no

discovery_address = DISC_ADDR
discovery_port = DISC_PORT

discovery_interval = DISC_PERIOD

EOF

    if [ ! -z $disc_lport ] ;  then
	echo "discovery_local_port = ${disc_lport}" >> ${conf_file}
    fi
}

# ------------------------------------------------------------
start_node() {
    #
    # Starts an IBRDTN node
    #
    # Uses the following variables:
    #
    # node_id        : id of the node (required)
    # node_start_time: time when the node should start (EPOCH in ms, OPTIONAL)
    # node_end_time  : time when the node should stop (EPOCH in ms, OPTIONAL)
    # node_seed      : seed to be used by that node's random generator (OPTIONAL)
    # itf            : interface the IBRDTN node should bind to (required)
    # disc_addr      : address to use for neighbor discovery (required)
    # disc_port      : port number to use for neighbor discovery (required)
    # disc_lport     : local port number to use for neighbor discovery (OPTIONAL)
    
    echo Starting node $node_id

    init

    if [ ! -d $node_dir ] ; then
	mkdir -p $node_dir
    fi
    
    
    options=""
    if [ ! -z $node_start_time ] ;  then
	options="--start $node_start_time"
    fi
    if [ ! -z $node_end_time ] && [ $node_end_time -gt 0 ] ;  then
	options="$options --stop $node_end_time"
    fi
    if [ ! -z $node_seed ] ;  then
	options="$options --seed $node_seed"
    fi

    # Generate a config file for that node (saved in ${node_dir}/conf)
    gen_conf_file

    ${dtnd} -q $options -c ${conf_file} &
    echo $! > $pid_file
}

# ------------------------------------------------------------
stop_node() {
    #
    # Stops an IBRDTN node
    #
    # Uses the following variables:
    #
    # node_id      : id of the node (required)

    echo Stopping node $node_id
    
    init

    check_running
    
    pid=$(cat $pid_file)
    kill $pid >& /dev/null
    rm -f $pid_file
}

# ------------------------------------------------------------
check_running() {
    
    if [ ! -e ${pid_file} ] ; then
	echo "Error: it seems node ${node_id} is not running"
	exit 1
    fi
}

# ------------------------------------------------------------
status() {
    #
    # Shows the status of an IBRDTN node (i.e. running or not running)
    #
    # node_id: id of the node (required)

    init

    if [ -e ${pid_file} ] ; then
	echo "Node ${node_id} is running"
    else
	echo "Node ${node_id} is not running"
    fi
}

# ------------------------------------------------------------
send() {
    #
    # Transfers a file between two IBRDTN nodes
    #
    # node_id: id of the source node (required)
    # $1     : id of the destination node (required)
    # $2     : file to be transferred (required)

    dst=$1
    fname=$2

    init
    
    if [ ! -e $fname ] ; then
	echo "Error: invalid file $fname"
	exit 1
    fi

    check_running
    
    ${dtnsend}  -U ${socket_file} dtn://${dst}/filetransfer $fname
}

# ------------------------------------------------------------
recv() {
    #
    # Receives files from other IBRDTN nodes
    #
    # node_id: id of the node that should receive files (required)

    init
    
    ${dtnrecv} -U ${socket_file} --name filetransfer
}

