#!/bin/bash

muon=${LEPTON_HOME%/*}/muon_tools

. ${muon}/bin/run_java.sh transform.DGS2History -inDGS $1  -outHist $2

# Repair the dgs file: (ex:remove an edge connecting one or two non existed node)
mv $1 tmp.dgs
. ${muon}/bin/run_java.sh transform.DGSRepairer -inDGS tmp.dgs -outDGS $1
rm tmp.dgs