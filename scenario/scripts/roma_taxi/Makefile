sample_size = 1000
max_node = 100
start = 0
length = 3600000


dgsScripts = ../dgs/
eventFile = taxi_events.txt
nodeFile = taxi_nodes.txt
outputFile = taxi_roma.dgs
outputFileMaxNode = taxi_roma_$(max_node).dgs
header = dgs_header.txt

in = ../taxi_february.txt
p = python3

sample: $(in)
	tail -n $(sample_size) $(in)|\
	$(p) shortenDate.py |\
	$(p) dateToTick.py |\
	$(p) lineToEvent.py |\
	$(p) $(dgsScripts)remove_dup_timestamp.py |\
	$(p) $(dgsScripts)dgs_reset_time_origin.py > $(eventFile)

header:
	$(p) $(dgsScripts)header.py $(header)
	
eventFile: $(in)
	cat $(in) |\
	$(p) shortenDate.py |\
	$(p) dateToTick.py |\
	$(p) lineToEvent.py |\
	$(p) $(dgsScripts)remove_dup_timestamp.py |\
	$(p) $(dgsScripts)dgs_reset_time_origin.py > $(eventFile)

nodeFile: $(eventFile)
	$(p) $(dgsScripts)node_creation.py $(eventFile) > $(nodeFile)

outputFile : header nodeFile $(eventFile)
	cat $(header) $(nodeFile) $(eventFile) > $(outputFile)

removebuildfiles :
	rm -f $(header) $(eventFile) $(nodeFile)
clean: removebuildfiles
	rm -f *.dgs

all: outputFile removebuildfiles
	cat $(outputFile) |\
	$(p) $(dgsScripts)dgs_cut.py $(start) $(length) |\
	$(p) $(dgsScripts)dgs_remove_nodes.py $(max_node) > $(outputFileMaxNode)
debug: outputFile
