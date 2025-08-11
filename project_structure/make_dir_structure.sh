#!/bin/bash
# Set up the directory structure for ONT data store 

# Create directory safely with -p 
safe_mkdir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created: $1"
    else
        echo "Exists:  $1"
    fi
}

# Base path: current directory
BASE_DIR=$(pwd)

# Define the full paths for each directory
dirs=(
    "$BASE_DIR/analysis/assembly/global_assembly/assembly_fasta"
    "$BASE_DIR/analysis/assembly/global_assembly/dot_plot"
    "$BASE_DIR/analysis/assembly/local_assembly/assembly_fasta"
    "$BASE_DIR/analysis/assembly/local_assembly/dot_plot"
    "$BASE_DIR/analysis/copyNumber/img"
    "$BASE_DIR/analysis/logs"
    "$BASE_DIR/analysis/variants"
    "$BASE_DIR/data/fastq/raw"
    "$BASE_DIR/data/fastq/trimmed"
    "$BASE_DIR/data/fastq/trimmed_filtered"
    "$BASE_DIR/data/fastq/trimmed_filtered_corrected"
    "$BASE_DIR/data/qc/raw"
    "$BASE_DIR/data/qc/trimmed"
    "$BASE_DIR/data/qc/trimmed_filtered"
    "$BASE_DIR/data/qc/trimmed_filtered_corrected"
    "$BASE_DIR/data/align/raw"
    "$BASE_DIR/data/align/trimmed"
    "$BASE_DIR/data/align/trimmed_filtered"
    "$BASE_DIR/data/align/trimmed_filtered_corrected"
    "$BASE_DIR/data/logs"
    "$BASE_DIR/results"
)

# Create each directory safely
for dir in "${dirs[@]}"; do
    safe_mkdir "$dir"
done

