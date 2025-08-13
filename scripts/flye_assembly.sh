#!/bin/bash
# Assemble a draft genome using Flye

USAGE="Usage: $0 -f <fastq> -o <output prefix> -g <est. genome size>"

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
size=0
threads=24
out_prefix=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-f | --fastq )
			fastq="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output_prefix )
			out_prefix="$2"
			shift 2
			;;
		-g | --est-genome-size )
			size="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="flye --nano-hq ${fastq} -o . -t ${threads} -g ${size}"

echo ${cmd} > "${out_prefix}.align_assembly.cmd"

eval ${cmd}

