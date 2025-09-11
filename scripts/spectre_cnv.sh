#!/bin/bash
# Use mosdepth and spectre to do Copy Number Variation (CNV) analysis
# Parameters:
bam=""		# PASSED VIA CLI
fasta=""	# PASSED VIA CLI
out_prefix=""	# PASSED VIA CLI
threads=24

USAGE="Usage: $0 -b <bam> -f <reference fasta> -o <output prefix>"

function print_usage_exit()
{
	if [[ ! -z $1 ]]; then
		echo -e "Unknown parameter '$1' \n${USAGE}"
		exit 1
	fi
	echo ${USAGE}
	exit 1
}

if [[ $# -eq 0 ]]; then
	echo $USAGE
	exit 1
fi

while [[ $# -gt 0 ]]; do
	case "$1" in
		-b | --bam )
			bam="$2"
			shift 2 # Shift past both argument and value
			;;
		-f | --fasta )
			fasta="$2"
			shift 2
			;;
		-o | --output_prefix )
			out_prefix="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

bam_full=$(realpath "${bam}")
fasta_full=$(realpath"${fasta}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename "$0")
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}" <<EOF
echo '1: Calculating read depth information'
mosdepth -t 8 -x -b 1000 -Q 20 ${out_prefix} ${bam_full}

echo '2: Calling CNV with Spectre'
spectre CNVCaller --coverage ${out_prefix}.mosdepth.regions.bed.gz --sample-id ${out_prefix} --output-dir . --reference ${fasta_full}
EOF

chmod +x "${script_name}"

echo "Wrote executable script: ${script_name}"

./"${script_name}"
