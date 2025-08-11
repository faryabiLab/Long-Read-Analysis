#!/bin/bash
# Run Herro preprocessing script 


USAGE="Usage: $0 -f <preprocessed fastq> -o <output prefix> -p <path to herro scripts dir>"

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
threads=24
out_prefix=""
dir=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-f | --preprocess_fastq )
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

cmd="
seqkit seq -ni ${fastq} > ${out_prefix}.readIDs.txt
${dir}/create_batched_alignments.sh ${fastq} ${out_prefix}.readIDs.txt ${threads} ./batched_alignments"

echo ${cmd} > "${out_prefix}.Herro_batch_align.cmd"

eval ${cmd}

