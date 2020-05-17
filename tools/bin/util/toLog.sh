#!/bin/bash

#
# Le script permet de changé tout les noms des fichiers de log des 
# noeuds, pour qu'ils puissent passé par le même analyseur aDTN.
#
#

# Usage
if [ $# -ne 1 ]; then
    echo "usage: $0 <folder_of_ibrDTN_node>"
    exit 1
fi


for f in $(find $1 -name log) ; 
do
    mv $f "$f.log"
done
