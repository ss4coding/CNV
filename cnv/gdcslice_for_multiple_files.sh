#!/bin/bash
#SBATCH --job-name=GDC-Download-sliced
#SBATCH --time=1:00:00
#SBATCH --ntasks=4
#SBATCH --partition=rra
#SBATCH --qos=rra
#SBATCH --mem-per-cpu=2048
#SBATCH --output=/dev/null # Necessary to delete the default empty Slurm files created
# TODO: YOU HAVE TO PUT YOUR ARRAYSIZE HERE (the length of your manifest rounded up to the nearst 100, +1
# For example if your manifest has 1259 lines of data, you would put 1301
#SBATCH --array=0-1301%100  


module purge
module add apps/gdc-client/1.3.0  # Re-added for loading necessary tools

# Get the arguments passed from the Python script
OutputFolder=$1
ChromosomalLocation=$2
PathToManifest=$3
PathToToken=$4

# Create the output directory if it doesn't exist
mkdir -p $OutputFolder  

# Redirect output files to the respective OutputFolder
exec > "$OutputFolder/output.$SLURM_JOB_ID" 2>&1

# Read the manifest file into an array
mapfile -t myArray < $PathToManifest

# Number of files in the manifest
NumberOfBams=${#myArray[@]}
echo $NumberOfBams

# Get the manifest entry for the current task
InputString=${myArray[$SLURM_ARRAY_TASK_ID]}
ID=$(cut -d' ' -f1 <<< $InputString)
NAME=$(cut -d' ' -f2 <<< $InputString)

# Read the token
token=$(<$PathToToken)

# Need to insert the proper ID
APItext="https://api.gdc.cancer.gov/slicing/view/$ID?region=$ChromosomalLocation&region=unmapped"

# Perform the download using the current OutputFolder and save to the mapped API URL
curl --header "X-Auth-Token: $token" $APItext --output "$OutputFolder/sliced_$NAME"

# If the curl request was not successful, indicate the error
if [ $? -ne 0 ]; then
  echo "Error occurred while downloading from $APItext ?"
  exit 1
fi
