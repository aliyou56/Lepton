#!/bin/bash

echo
echo
echo "Traitement des résultats"
echo
#sleep 10

folderResult="$(date '+%Y-%m-%d::%H:%M:%S')_$1"

# Répertoire des résultats de lepton et ibrDTN
if [ ! -d "${LEPTON_HOME}/result/$folderResult/" ]; then
    mkdir "${LEPTON_HOME}/result/$folderResult/"
fi

# Copie des résultats dans ${LEPTON_HOME}/result

folderOutirbdtn="/dev/shm/$USER/ibrdtn"
cp -r $folderOutirbdtn ${LEPTON_HOME}/result/$folderResult

mkdir "${LEPTON_HOME}/result/$folderResult/lepton"

mv ${LEPTON_HOME}/*.err ${LEPTON_HOME}/result/$folderResult/lepton
mv ${LEPTON_HOME}/*.out ${LEPTON_HOME}/result/$folderResult/lepton
mv ${LEPTON_HOME}/lepton-pid ${LEPTON_HOME}/result/$folderResult/lepton
mv ${LEPTON_HOME}/*.dgs ${LEPTON_HOME}/result/$folderResult/lepton


echo "Début des traitements des résultats"
echo

${LEPTON_HOME}/tools/bin/util/toLog.sh ${LEPTON_HOME}/result/$folderResult/ibrdtn
python ${LEPTON_HOME}/tools/bin/util/log_ibrdtn_out_to_log_adtn.py ${LEPTON_HOME}/result/$folderResult/lepton/lepton.out
python ${LEPTON_HOME}/tools/bin/util/modificateurDeLog.py lepton/result/$folderResult/ibrdtn/
mv ${LEPTON_HOME}/newLogNodesOflepton ${LEPTON_HOME}/result/$folderResult
cd ${LEPTON_HOME}/tools/bin/util/logAnalyser/src/main/scala/
scalac LogAnalyser.scala
scala Main ${LEPTON_HOME}/result/$folderResult/lepton/lepton.outToAdtn.out ${LEPTON_HOME}/result/$folderResult/newLogNodesOflepton ibrdtn
cd ${LEPTON_HOME}
mv tools/bin/util/logAnalyser/src/main/scala/output.txt ${LEPTON_HOME}/result/$folderResult

echo "Fin des traitements des résultats"
echo

