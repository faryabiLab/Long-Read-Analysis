#!/bin/bash
# Use mosdepth and spectre to do Copy Number Variation (CNV) analysis


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

bam=""
assem=""
threads=24
out_prefix=""
fasta=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-b | --bam )
			bam="$2"
			shift 2 # Shift past both argument and value
			;;
		-f | --fasta )
			fasta-"$2"
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

cmd="
echo '1: Calculating read depth information'
mosdepth -t 8 -x -b 1000 -Q 20 ${out_prefix} ${bam}

echo '2: Calling CNV with Spectre'
spectre CNVCaller --coverage ${out_prefix}.mosdepth.regions.bed.gz --sample-id ${out_prefix} --output-dir . --reference ${fasta}
"

echo ${cmd} > "${out_prefix}.Spectre_CNV.cmd"

eval ${cmd}

