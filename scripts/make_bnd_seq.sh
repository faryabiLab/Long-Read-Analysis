#!/bin/bash

# Usage:
# ./subset_fasta.sh -a input.fasta -o output.fasta -r chr1:100-200 -r chr2:500-700 ...

set -euo pipefail

# Defaults
regions=()
out="subset.fa"

while getopts "a:o:r:" opt; do
  case $opt in
    a) fasta=$OPTARG ;;
    o) out=$OPTARG ;;
    r) regions+=("$OPTARG") ;;
    *) echo "Usage: $0 -a fasta -o out -r chr:start-end [-r chr:start-end ...]" >&2; exit 1 ;;
  esac
done

if [[ -z "${fasta:-}" || ${#regions[@]} -eq 0 ]]; then
  echo "ERROR: Must provide FASTA (-a) and at least one region (-r)." >&2
  exit 1
fi

# Check fasta index
if [[ ! -f "${fasta}.fai" ]]; then
  echo "Index not found for $fasta, creating..."
  samtools faidx "$fasta"
fi

> "$out"

for r in "${regions[@]}"; do
  echo "Extracting $r ..."
  seq=$(samtools faidx "$fasta" "$r" 2>/dev/null || true)
  if [[ -z "$seq" ]]; then
    echo "ERROR: No sequence returned for $r. Check FASTA contig names/coords." >&2
    exit 1
  fi
  echo "$seq" >> "$out"
done

echo "Output written to $out"

