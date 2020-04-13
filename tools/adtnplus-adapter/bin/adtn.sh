#!/bin/bash

#---------------------------------------------------------------------
#  Script for managing aDTNPlus nodes - adtnplus adapter for lepton
#     
#  Need the following variables to be set
#	  - ADTNPLUS_HOME
#	  - ADTNPLUS_ADAPTER_HOME
#---------------------------------------------------------------------

if [ -z $ADTNPLUS_HOME ]; then
    echo "Error: \$ADTNPLUS_HOME is not defined."
    exit 1
fi

if [ -z $ADTNPLUS_ADAPTER_HOME ]; then
    echo "Error: \$ADTNPLUS_ADAPTER_HOME is not defined."
    exit 1
fi

#  Load utility functions
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

# ------------------------------------------------------------

if [ "$1" == "-h" ] ; then
    usage
fi

if [ -z $node_id ] ; then
    node_id=$HOSTNAME
fi


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
	if [ $# -lt 2 ] ; then
	    usage
	fi
	shift 
	send $*
	;;
    recv)
	if [ $# -lt 1 ] ; then
	    usage
	fi
	shift
	recv $*
	;;
    *)
	usage
	;;
esac
