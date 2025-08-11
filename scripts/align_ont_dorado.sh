#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -f <reference fasta> -a <assembly fasta> -o <output prefix> -p <dorado path>"

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

ref=""
assem=""
threads=24
out_prefix=""
path=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-f | --fasta )
			ref="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output_prefix )
			out_prefix="$2"
			shift 2
			;;
		-a | --assembly_fasta )
			assem="$2"
			shift 2
			;;
		-p | --dorado-path )
			path="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="${path}/dorado aligner --output-dir . --emit-summary --threads ${threads} --mm2-opts '-Y' ${assem} ${fastq}"

echo ${cmd} > "${out_prefix}.align_dorado.cmd"

eval ${cmd}

