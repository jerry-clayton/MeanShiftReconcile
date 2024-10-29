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
lasfile=$(ls "$input_dir"/*.las 2>/dev/null)
tarball=$(ls "$input_dir"/*.tar.gz 2>/dev/null)

echo "tarball: $tarball"
echo "lasfile: $lasfile"

tar -xvf "$tarball" -C "$input_dir"
las_path="$parent_path/input/$lasfile"
outfile="segmented_merged_${lasfile}"
output_path="$parent_path/output/$outfile"

# echo "R package install script ran succedssfully."
echo "Running  MeanShift segmentation"
# Run the R script
Rscript --verbose ${basedir}/run/combine_tiles.R "$las_path" "$input_dir" 

# Check if the R script ran successfully
if [[ $? -ne 0 ]]; then
  echo "Failed to run the R script."
  exit 1
fi

echo "R package install script ran succedssfully."

# Deactivate the conda environment (optional)
conda deactivate
