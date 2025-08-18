#!/bin/bash
# concat_fasta.sh
#
# Usage:
# ./concat_fasta.sh -a reference.fa -o output.fa -r chr11:100000-200000 -r chr14:50000-150000

set -euo pipefail

regions=()
out="concatenated.fa"

while getopts "a:o:r:" opt; do
  case $opt in
    a) fasta=$OPTARG ;;
    o) out=$OPTARG ;;
    r) regions+=("$OPTARG") ;;
    *) echo "Usage: $0 -a fasta -o out -r chr:start-end [-r chr:start-end ...]" >&2; exit 1 ;;
  esac
done

if [[ -z "${fasta:-}" || ${#regions[@]} -lt 2 ]]; then
  echo "ERROR: Must provide FASTA (-a) and at least two regions (-r)." >&2
  exit 1
fi

# Ensure fasta is indexed
if [[ ! -f "${fasta}.fai" ]]; then
  echo "Index not found for $fasta, creating..."
  samtools faidx "$fasta"
fi

tmpseq=$(mktemp)

for r in "${regions[@]}"; do
  echo "Extracting $r ..."
  # Extract subsequence with samtools
  seq=$(samtools faidx "$fasta" "$r" 2>/dev/null || true)
  if [[ -z "$seq" ]]; then
    echo "ERROR: No sequence returned for $r. Check contig names/coords." >&2
    exit 1
  fi
  # Skip header, append raw sequence to tmp
  echo "$seq" | grep -v "^>" >> "$tmpseq"
done

# Write final concatenated FASTA
{
  echo ">concatenated_${regions[0]}_${regions[1]}"
  fold -w 60 "$tmpseq"
} > "$out"

rm "$tmpseq"
echo "Wrote concatenated sequence to $out"

