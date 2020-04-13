#!/bin/bash

dgs=$1
aevt=$2

# generate the aevt file from the dgs file
scala ./libs/aevt-generator.jar $dgs $aevt