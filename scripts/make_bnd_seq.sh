#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: $0 -a <assembly.fasta> -o <output prefix> -r <chr:start-end[:+|->> [-r <...>] [--name <seq_name>]
Example:
  $0 -a hg38.fa -o der_chr11_14 \\
     -r chr11:10000-110000:+ -r chr14:10000-1000000    # chr14 forward
  $0 -a hg38.fa -o der_chr11_14 \\
     -r chr11:10000-110000 -r chr14:10000-1000000:-    # chr14 reverse-complement

Notes:
  - Order of -r arguments = splice order in output
  - Strand suffix optional; default '+'
"

function print_usage_exit() {
    if [[ ! -z ${1:-} ]]; then
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

assem=""
out_prefix=""
name=""
declare -a regions=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--assembly_fasta)
            assem="$2"; shift 2 ;;
        -o|--output_prefix)
            out_prefix="$2"; shift 2 ;;
        -r|--region)
            regions+=("$2"); shift 2 ;;
        --name)
            name="$2"; shift 2 ;;
        -*|--*)
            print_usage_exit "$1" ;;
        *)
            print_usage_exit ;;
    esac
done

# ---- checks ----
command -v samtools >/dev/null 2>&1 || { echo "ERROR: samtools not found in PATH"; exit 1; }
[[ -n "$assem" && -f "$assem" ]] || { echo "ERROR: -a/--assembly_fasta required and must exist"; echo "${USAGE}"; exit 1; }
[[ -n "$out_prefix" ]] || { echo "ERROR: -o/--output_prefix required"; echo "${USAGE}"; exit 1; }
[[ ${#regions[@]} -ge 1 ]] || { echo "ERROR: at least one -r/--region required"; echo "${USAGE}"; exit 1; }

out_fa="${out_prefix}.concat.fa"
cmd_log="${out_prefix}.concat.cmd"

# Index FASTA if needed
if [[ ! -f "${assem}.fai" ]]; then
    echo "samtools faidx '${assem}'" > "${cmd_log}"
    samtools faidx "${assem}"
else
    : > "${cmd_log}"
fi

# Build header if not provided
if [[ -z "${name}" ]]; then
    name="$(IFS='|'; echo "${regions[*]}")"
fi

# Temp file for concatenated sequence (single line)
tmp_seq="$(mktemp)"
trap 'rm -f "${tmp_seq}"' EXIT
: > "${tmp_seq}"

# IUPAC complement table (upper+lower)
IUPAC_SRC='ACGTRYKMSWBDHVNacgtrykmswbdhvn'
IUPAC_DST='TGCAYRMKSWVHDBNtgcayrmkswvhdbn'

# Process regions in order
for reg in "${regions[@]}"; do
    # Parse chr:start-end[:strand]
    if [[ "$reg" =~ ^([^:]+):([0-9]+)-([0-9]+)(:([+-]))?$ ]]; then
        chr="${BASH_REMATCH[1]}"
        start="${BASH_REMATCH[2]}"
        end="${BASH_REMATCH[3]}"
        strand="${BASH_REMATCH[5]:-+}"
    else
        echo "ERROR: Bad region format: '$reg' (expected chr:start-end[:+|-])"
        exit 1
    fi

    # Ensure start <= end
    if (( start > end )); then
        tmp="${start}"; start="${end}"; end="${tmp}"
    fi
    query="${chr}:${start}-${end}"

    echo "samtools faidx '${assem}' '${query}'" >> "${cmd_log}"
    seq=$(samtools faidx "${assem}" "${query}" | sed -n '2,$p' | tr -d '\n' || true)
    if [[ -z "${seq}" ]]; then
        echo "ERROR: No sequence returned for ${query}. Check FASTA contig names/coords."
        exit 1
    fi

    if [[ "${strand}" == "-" ]]; then
        echo "# reverse-complement ${query}" >> "${cmd_log}"
        # complement then reverse
        seq=$(echo -n "${seq}" | tr "${IUPAC_SRC}" "${IUPAC_DST}" | rev)
    fi

    printf "%s" "${seq}" >> "${tmp_seq}"
done

# Write FASTA with wrap at 60 cols
{
    echo ">${name}"
    fold -w 60 "${tmp_seq}"
} > "${out_fa}"

echo "Wrote ${out_fa}"
echo "Commands logged to ${cmd_log}"

