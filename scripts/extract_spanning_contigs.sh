#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: $0 -b <input.bam> -o <output prefix> [-q <min MAPQ>] [-F <exclude flags>]
  -b, --bam              Input BAM (indexed not required)
  -o, --output_prefix    Output prefix
  -q, --min-mapq         Minimum MAPQ to keep (default: 0)
  -F, --exclude-flags    samtools -F mask (default: 260 = exclude unmapped(0x4) and secondary(0x100))
"

function print_usage_exit() {
    if [[ ! -z "${1:-}" ]]; then
        echo -e "Unknown parameter '$1'\n${USAGE}"
        exit 1
    fi
    echo "${USAGE}"
    exit 1
}

if [[ $# -eq 0 ]]; then
    echo "${USAGE}"
    exit 1
fi

bam=""
out_prefix=""
min_mapq=0
exclude_flags=260   # exclude unmapped + secondary; keep supplementary

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--bam)
            bam="$2"; shift 2 ;;
        -o|--output_prefix)
            out_prefix="$2"; shift 2 ;;
        -q|--min-mapq)
            min_mapq="$2"; shift 2 ;;
        -F|--exclude-flags)
            exclude_flags="$2"; shift 2 ;;
        -*|--*)
            print_usage_exit "$1" ;;
        *)
            print_usage_exit ;;
    esac
done

# ---- checks ----
command -v samtools >/dev/null 2>&1 || { echo "ERROR: samtools not found in PATH"; exit 1; }
[[ -n "$bam" && -f "$bam" ]] || { echo "ERROR: -b/--bam required and must exist"; echo "${USAGE}"; exit 1; }
[[ -n "$out_prefix" ]] || { echo "ERROR: -o/--output_prefix required"; echo "${USAGE}"; exit 1; }

tmp_all="$(mktemp)"
tmp_names="$(mktemp)"
trap 'rm -f "$tmp_all" "$tmp_names"' EXIT

# ---- pipeline ----
# 1) Extract (QNAME, RNAME, POS, CIGAR, MAPQ) from BAM, filter by flags & MAPQ
# 2) Find QNAMEs with >1 distinct chromosome
# 3) Keep only rows for those QNAMEs
cmd_extract="samtools view -F ${exclude_flags} '${bam}' \
  | awk -v q=${min_mapq} 'BEGIN{OFS=\"\t\"} (\$3!=\"*\" && \$5>=q){print \$1,\$3,\$4,\$6,\$5}' \
  > '${tmp_all}'"

cmd_multichr="cut -f1,2 '${tmp_all}' | sort -u \
  | awk -F'\t' '{c[\$1]++} END{for(k in c) if(c[k]>1) print k}' > '${tmp_names}'"

cmd_filter="( echo -e 'qname\tchrom\tpos\tcigar\tmapq'; \
  awk 'NR==FNR{keep[\$1]=1; next} (\$1 in keep){print}' '${tmp_names}' '${tmp_all}' \
  | sort -k1,1 -k2,2 -k3,3n ) > '${out_prefix}.multi_chrom.tsv'"

# Save a reproducible .cmd log
{
  echo "${cmd_extract}"
  echo "${cmd_multichr}"
  echo "${cmd_filter}"
} > "${out_prefix}.multichrom.cmd"

# Execute
eval "${cmd_extract}"
eval "${cmd_multichr}"
eval "${cmd_filter}"

# Optional: also write just the list of QNAMEs
cut -f1 "${out_prefix}.multi_chrom.tsv" | tail -n +2 | sort -u > "${out_prefix}.multi_chrom.qnames.txt"

echo "Done."
echo "Output table: ${out_prefix}.multi_chrom.tsv"
echo "QNAME list   : ${out_prefix}.multi_chrom.qnames.txt"

