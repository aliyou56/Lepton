
#---------------------------------------------------------------------
#  Utility functions - adtnplus adapter for lepton
#---------------------------------------------------------------------

#---------------------------------------------------------------------
init_dirs () {
  #
  # Initialize all needed directories for adtnplus files
  # 
  # LEPTON_HOME: lepton home dir

	dir=${LEPTON_HOME%/*}
	base_dir=$dir/output/adtn
	node_dir=${base_dir}/${node_id}
	pid_file=${node_dir}/pid
	conf_file=${node_dir}/adtn.ini
	node_file=${node_dir}/NodeState.json
}

#---------------------------------------------------------------------
init_vars () {
  #
  # Initialize needed variables for the configuration file
  #  
  # use lockfile command (from procmail paquet -> sudo apt install procmail)

	# Variables for the configuration
	log_level=21
	queue_size="1M"
	# -------------------
  DEFAULT_START_PORT=40000

	port_aux_dir="/run/shm/tmp"
	if [ ! -d $port_aux_dir ]; then
		mkdir -p $port_aux_dir
		echo $DEFAULT_START_PORT > $port_aux_dir/port_aux
	fi

	lockfile -1 -r-1 -l3 $port_aux_dir/port_aux.lock ### Semaphore port_aux

	START_PORT_ACCEPT=$(cat $port_aux_dir/port_aux)
  node_port=${START_PORT_ACCEPT} 
  ((++START_PORT_ACCEPT))
  list_port=${START_PORT_ACCEPT} 
  ((++START_PORT_ACCEPT))
  echo $START_PORT_ACCEPT > $port_aux_dir/port_aux
  # next_port; node_port=${START_PORT_ACCEPT} 
  # next_port; list_port=${START_PORT_ACCEPT} 
  # next_port; echo $START_PORT_ACCEPT > $port_aux_dir/port_aux
	
	rm -f $port_aux_dir/port_aux.lock              ### end Semaphore port_aux
}

#---------------------------------------------------------------------
# next_port() {
#   #
#   # Get the next free port number and put it into START_PORT_ACCEPT 
#   #
#   # START_PORT_ACCEPT:  

#   if [ $START_PORT_ACCEPT -gt 65535 ] ; then
#     let START_PORT_ACCEPT=$DEFAULT_START_PORT
#   fi

#   $(nc -z 127.0.0.1 $START_PORT_ACCEPT)
#   ret=$?
#   while [ $ret -eq 0 ]; do
#     ((++START_PORT_ACCEPT))
#     $(nc -z 127.0.0.1 $START_PORT_ACCEPT); let ret=$?

#     if [ $START_PORT_ACCEPT -gt 65535 ] ; then
#       let START_PORT_ACCEPT=$DEFAULT_START_PORT
#     fi
#   done
# }

#---------------------------------------------------------------------
gen_conf_file() {
  # 
  # Generate a configuration file for an adtnplus node
  #
  # node_id   : id of the node (required)
  # node_addr : address of the node (required)
  # node_port : port number used by the node (required)
  # disc_addr : address to use for neighbor discovery (required)
  # disc_port : port number to use for neighbor discovery (required)
  # log_level : the level of the log (required)
  # node_dir  : directory for the logs produced by that node (required)
  # list_addr : address to use for listening (required)
  # list_port : port number to use for listening (required)

  cat <<EOF | sed -e s%NODE_ID%${node_id}%g \
                  -e s%NODE_ADDR%${node_addr}%g \
                  -e s%NODE_PORT%${node_port}%g \
                  -e s%DISC_ADDR%${disc_addr}%g \
                  -e s%DISC_PORT%${disc_port}%g \
                  -e s%DISC_PERI%${hub_period}%g \
                  -e s%LOG_LEVEL%${log_level}%g \
                  -e s%QUEUE_SIZE%${queue_size}%g \
                  -e s%NODE_DIR%${node_dir}%g \
                  -e s%LIST_ADDR%${list_addr}%g \
                  -e s%LIST_PORT%${list_port}%g \
                  -e s%NODE_FILE%${node_file}%g \
          > ${conf_file}
# This file contains the configuration of the aDTNPlus.

[Node]
nodeId : NODE_ID
nodeAddress : NODE_ADDR
nodePort : NODE_PORT
# Clean the previous bundles
clean : false

[NeighbourDiscovery]
discoveryAddress : DISC_ADDR
discoveryPort : DISC_PORT
# discoveryPeriod : 2
discoveryPeriod : DISC_PERI

neighbourExpirationTime : 6 ## 4
neighbourCleanerTime : 4 ## 2
testMode : false

[Logger]
filename : NODE_DIR/adtn.log
level : LOG_LEVEL

[Constants]
timeout : 10
queueByteSize : QUEUE_SIZE
processTimeout : 10

[BundleProcess]
dataPath : NODE_DIR/Bundles/
bundleProcessName : NODE_DIR/Plugins/libaDTNPlus_FirstFwkBundleProcessor.so
# codePath : NODE_DIR/Codes/ 
deliveryPath : NODE_DIR/Delivered/
trashAggregationReception : NODE_DIR/Trash/aggregation/reception/
trashAggregationDelivery : NODE_DIR/Trash/aggregation/delivery/
trashDropp : NODE_DIR/Trash/drop/

[AppListener]
listenerAddress : LIST_ADDR
listenerPort : LIST_PORT

[NodeState]
path : NODE_FILE 

EOF

}

#---------------------------------------------------------------------
gen_nodeState_file() {
  #
  # Generate a node state file for an adtnplus node
  #
  # node_id   : id of the node (required)
  # log_level : the level of the log (required)

  cat <<EOF | sed -e s%NODE_ID%${node_id}%g \
                  -e s%LOG_LEVEL%${log_level}%g \
        > ${node_file}
{
  "configuration" : {
    "defaultCodes" : {
      "forwarding" : "if (bps[\"delivered\"]) {bps[\"discard\"] = true; return std::vector<std::string>();} else {auto neighbours = ns(\"eid.connected.all\"); std::vector<std::string> toSend = std::vector<std::string>(); if (neighbours.size() > 0) {int pos = rand() % neighbours.size(); toSend.push_back(neighbours[pos]);}return toSend;}",
      "lifetime" : "uint64_t creationTimestamp = bs(\"timestamp.value\"); if(bs(\"lifetime\") < (time(NULL) - g_timeFrom2000 - creationTimestamp)) return true; else return false;",
      "destination" : "auto destination = bs(\"destination\"); auto endpoints = ns(\"eid.registered\"); if(std::find(endpoints.begin(), endpoints.end(), destination) != endpoints.end()) return std::vector<std::string>({destination}); else return std::vector<std::string>();",
      "creation" : "bps[\"delivered\"] = false; bps[\"discard\"] = false; bps[\"forwarded\"] = false;",
      "deletion" : ""
    },
    "logLevel" : LOG_LEVEL
  },
  "state" : {
    "stop" : false,
    "changed" : false
  },
  "id" : "NODE_ID"
}			

EOF

}

#---------------------------------------------------------------------
check_running() {
  if [ ! -e ${pid_file} ] ; then
	  echo "Error: it seems node ${node_id} is not running"
	  exit 1
  fi
}

#---------------------------------------------------------------------
status() {
  #
  # Shows the status of an aDTN node (i.e. running or not running)
  #
  # node_id: id of the node (required)

  init_dirs

  if [ -e ${pid_file} ] ; then
    echo "Node ${node_id} is running"
  else
    echo "Node ${node_id} is not running"
  fi
}

#---------------------------------------------------------------------
send() {
  #
  # Transfers a file between two aDTNPlus nodes
  #
  # node_id: id of the source node (required)
  # $1     : id of the destination node (required)
  # $2     : message to be send (required)

  echo Sending message from $node_id to $1

  dst=$1
  message=${*:2:$#}

  # echo $message
  echo \"$message\"

  init_dirs

  check_running

  ip_src=$(cat $conf_file | grep nodeAddress | cut -d" " -f 3)
  port_src=$(cat $conf_file | grep nodePort | cut -d" " -f 3)

  echo $adtnsend -i $ip_src -p $port_src -d $dst -m "$message"
  $adtnsend -i $ip_src -p $port_src -d $dst -m "$message"
}

#---------------------------------------------------------------------
recv() {
  #
  # Receive files from other aDTNPlus nodes
  #
  # node_id: id of the node that should receive messages (required)

  echo Receiving file on node $node_id

  init_dirs

  check_running

  ip_listen=$(cat $conf_file | grep listenerAddress | cut -d" " -f 3)
  port_listen=$(cat $conf_file | grep listenerPort | cut -d" " -f 3)
  
  $adtnrecv -i $ip_listen -p $port_listen -a $node_id
}
