#!/bin/bash
# Trim ONT reads in a fastq file with porechop


USAGE="Usage: $0 -f <fastq to trim> -o <output prefix>"

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
path=""

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

cmd="porechop -i ${fastq} -o ${output_prefix}_trimmed.fastq.gz -t ${threads} -v 3"

echo ${cmd} > "${out_prefix}.align_dorado.cmd"

eval ${cmd}

