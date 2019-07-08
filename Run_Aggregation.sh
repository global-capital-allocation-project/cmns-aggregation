#!/bin/bash
# --------------------------------------------------------------------------------------------------
# Run_Aggregation
#
# This bash script is the main executable file for the project.
#
# Notes:
#	- Please replace the following with the appropriate variables/paths for your system:
#		<CODE_PATH>: Path to the project code on the host system
# --------------------------------------------------------------------------------------------------

# Set this flag to 1 in order to run the build of the aggregation data sources
run_data_sources_build=0

# Preliminary step: Build of the data sources
if [ ${run_data_sources_build} = 1 ]; then
	stata-mp -b "<CODE_PATH>/Build_Data_Sources.do"
else

# Run the aggregation procedure
python "<CODE_PATH>/up_aggregation/.py"

exit
