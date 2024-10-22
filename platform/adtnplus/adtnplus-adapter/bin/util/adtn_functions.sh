
#---------------------------------------------------------------------
#  Utility functions - adtnplus adapter for lepton
#---------------------------------------------------------------------

#---------------------------------------------------------------------
init_dirs () {
  #
  # Initialize all needed directories for adtnplus files
  # 

	dir=${LEPTON_HOME} 
  [[ "${LEPTON_VAR}" != "" ]] && dir=$(dirname $(dirname ${LEPTON_VAR}))
	base_dir=${dir}/output/adtn
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

	port_dir="/run/shm/tmp"

	lockfile -1 -r-1 -l3 ${port_dir}/port_aux.lock ### Semaphore port_aux

	START_PORT_ACCEPT=$(cat ${port_dir}/port_aux)
  node_port=${START_PORT_ACCEPT} 
  ((++START_PORT_ACCEPT))
  list_port=${START_PORT_ACCEPT} 
  ((++START_PORT_ACCEPT))
  echo $START_PORT_ACCEPT > ${port_dir}/port_aux

	rm -f ${port_dir}/port_aux.lock              ### end Semaphore port_aux
}

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
                  -e s%NHB_EXP_TIME%${neighbour_expiration_time}%g \
                  -e s%NHB_CLEAN_TIME%${neighbour_cleaner_time}%g \
                  -e s%LOG_LEVEL%${log_level}%g \
                  -e s%TIMEOUT%${timeout}%g \
                  -e s%QUEUE_SIZE%${queue_size}%g \
                  -e s%NODE_DIR%${node_dir}%g \
                  -e s%LIST_ADDR%${list_addr}%g \
                  -e s%LIST_PORT%${list_port}%g \
                  -e s%NODE_FILE%${node_file}%g \
                  -e s%PROCESSOR%${processor}%g \
          > ${conf_file}
# This file contains the configuration of the aDTNPlus.

[Node]
nodeId : NODE_ID
nodeAddress : NODE_ADDR
nodePort : NODE_PORT
# Clean the previous bundles
# clean : true

[NeighbourDiscovery]
discoveryAddress : DISC_ADDR
discoveryPort : DISC_PORT
discoveryPeriod : DISC_PERI

# neighbourExpirationTime : NHB_EXP_TIME
# neighbourCleanerTime : NHB_CLEAN_TIME
# testMode : false

[Logger]
filename : NODE_DIR/adtn.log
level : LOG_LEVEL

[Constants]
# timeout : TIMEOUT
queueByteSize : QUEUE_SIZE
# processTimeout : 30

[BundleProcess]
dataPath : NODE_DIR/Bundles/
bundleProcessName : NODE_DIR/Plugins/PROCESSOR
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

  # echo Sending message from $node_id to $1

  dst=$1
  message=${*:2:$#}

  # echo $message
  # echo \"$message\"

  init_dirs
  check_running

  ip_src=$(cat ${conf_file} | grep nodeAddress | cut -d" " -f 3)
  port_src=$(cat ${conf_file} | grep nodePort | cut -d" " -f 3)

  echo $adtnsend -i ${ip_src} -p ${port_src} -d ${dst} -m "${message}" -s ${node_id}
  ${adtnsend} -i ${ip_src} -p ${port_src} -d ${dst} -m "${message}" -s ${node_id} 
}

#---------------------------------------------------------------------
recv() {
  #
  # Receive files from other aDTNPlus nodes
  #
  # node_id: id of the node that should receive messages (required)

  # echo Receiving file on node $node_id

  init_dirs
  check_running

  ip_listen=$(cat ${conf_file} | grep listenerAddress | cut -d" " -f 3)
  port_listen=$(cat ${conf_file} | grep listenerPort | cut -d" " -f 3)
  
  ${adtnrecv} -i ${ip_listen} -p ${port_listen} -a ${node_id}
}
