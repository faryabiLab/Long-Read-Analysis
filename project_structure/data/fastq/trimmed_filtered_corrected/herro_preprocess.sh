#!/bin/bash
# Run Herro preprocessing script 


USAGE="Usage: $0 -f <fastq> -o <output prefix> -p <path to herro scripts dir>"

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
dir=""

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
		-p | --path )
			dir="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="${dir}/preprocess.sh ${fastq} ${out_prefix} 16 16"
echo ${cmd} > "${out_prefix}.Herro_preprocess.cmd"

eval ${cmd}

