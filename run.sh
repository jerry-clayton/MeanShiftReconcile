#!/bin/bash

#get command arguments to pass to rscript

# Activate the 'ms-env' conda environment
basedir=$( cd "$(dirname "$0")" ; pwd -P)

source $(conda info --base)/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate ms-env

echo "Current Conda environment: $(conda info --envs | grep '*' | awk '{print $1}')"

echo "Basedir: ${basedir}"
echo "Working directory: $(pwd)"
# Check if the conda environment was activated
if [[ $? -ne 0 ]]; then
  echo "Failed to activate the conda environment 'ms-env'."
  exit 1
fi

parent_path=$(realpath .)
input_dir="$parent_path/input/"
#get LAS file
las_path=$(ls "$input_dir"*.las 2>/dev/null)
tarball=$(ls "$input_dir"*.tar.gz 2>/dev/null)

echo "tarball: $tarball"
echo "las_path: $las_path"

# isolate las filename for output construction; 
# split the filename on the / char and get last part 
IFS='/' read -ra parts <<< "$las_path"
lasfile="${parts[-1]}"

echo "las filename: ${lasfile}"

outfile="segmented_reconciled_${lasfile}"
output_path="$parent_path/output/$outfile"

echo "output path: $output_path"
# echo "R package install script ran succedssfully."
echo "Reconciling files in $tarball with $lasfile and saving output to $outfile"
# Run the R script
Rscript --verbose ${basedir}/run/combine_tiles.R "$las_path" "$tarball" "$output_path"

# Check if the R script ran successfully
if [[ $? -ne 0 ]]; then
  echo "Failed to run the R script."
  exit 1
fi

echo "R package install script ran succedssfully."

# Deactivate the conda environment (optional)
conda deactivate
