#!/bin/bash

#---------------------------------------------------------------------
#  Script for managing aDTNPlus nodes
#     
#  Need the following variable to be set
#	  - ADTNPLUS_ADAPTER_HOME
#---------------------------------------------------------------------

if [ -z ${ADTNPLUS_ADAPTER_HOME} ]; then
    echo "Error: \$ADTNPLUS_ADAPTER_HOME is not defined."
    exit 1
fi

# ------------------------------------------------------------
#  Load utility functions
# ------------------------------------------------------------
. ${ADTNPLUS_ADAPTER_HOME}/bin/util/adtn_functions.sh
. ${ADTNPLUS_ADAPTER_HOME}/bin/adapter.sh

# ------------------------------------------------------------
usage() {
    echo ""
    echo "Usage: adtn.sh start"
    echo "             | stop"
    echo "             | status"
    echo "             | send <dest> <fname>"
    echo "             | recv"
    echo ""
    exit -1
}

[[ "$1" == "-h" ]] && usage

[[ -z ${node_id} ]] && node_id=$HOSTNAME # set node_id value to HOSTNAME if not defined.

case $1 in
    start)
	start_node
	;;
    stop)
	stop_node
	;;
    status)
	status
	;;
    send)
    [[ $# -lt 2 ]] && usage
	shift 
	send $*
	;;
    recv)
    [[ $# -lt 1 ]] && usage
	shift
	recv $*
	;;
    *)
	usage
	;;
esac
