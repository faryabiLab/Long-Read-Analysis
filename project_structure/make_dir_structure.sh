#!/bin/bash

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
    "$BASE_DIR/data/qc"
    "$BASE_DIR/data/raw"
    "$BASE_DIR/data/trimmed_align"
    "$BASE_DIR/data/trimmed_fastq"
    "$BASE_DIR/data/trimmed_filtered"
    "$BASE_DIR/results"
)

# Create each directory safely
for dir in "${dirs[@]}"; do
    safe_mkdir "$dir"
done

