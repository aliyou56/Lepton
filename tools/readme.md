
# Scenario Launching

- Install Lepton, aDTN and ibrDTN plateforme (aDTN and ibrDTN installation instructions can be found in `plateform` directory) 
- Run one of the following scripts:
  - `bin/run_adtn.sh <scenario>` to run with aDTN nodes.
  - `bin/run_ibrdtn.sh <scenario>` to run with ibrDTN nodes.

# Note 
Discovery period for each system is initialized with the value of Lepton parameter (`hub_period`).
This configuration is done in the adapter function' script (`${ADTNPLUS_ADAPTER_HOME}/bin/util/adtn_functions.sh` 
and `${IBRDTN_ADAPTER_HOME}/bin/util/ibrdtn_functions.sh`) 