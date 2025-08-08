#!/bin/bash
# Wrapper for FiltLong; filter long reads by length


USAGE="Usage: $0 -f <ONT fastq> -o <output prefix>"

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
threads=48
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
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="filtlong --keep_percent 90 ${fastq} > ${output_prefix}.fastq"
echo ${cmd} > "${out_prefix}.FiltLong.cmd"

eval ${cmd}

