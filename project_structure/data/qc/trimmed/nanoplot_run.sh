#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -f <reference fasta>"

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

fastq=""
assem=""
threads=24
out_prefix=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-f | --fasta )
			fastq="$2"
			shift 2 # Shift past both argument and value
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

cmd="NanoPlot -t ${threads} --fastq ${fastq} -o . -p ${out_prefix} --raw --tsv_stats --info_in_report"
echo ${cmd} > "${out_prefix}.NanoPlot.cmd"

eval ${cmd}

