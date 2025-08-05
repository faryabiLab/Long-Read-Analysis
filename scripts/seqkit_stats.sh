#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -f <fasta> -o <out prefix>"

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

fasta=""
out_prefix=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-f | --fasta )
			fasta="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output )
			out_prefix="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="seqkit stats ${fasta} --all > ${out_prefix}.stats"

echo ${cmd} > "${out_prefix}.seqkitStats.cmd"

eval ${cmd}

