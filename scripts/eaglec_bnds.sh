#!/bin/bash
# Run EagleC on a .mcool 3C matrix.

USAGE="Usage: $0 -m <mcool file> -o <output prefix>"

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

cmd="predictSV --hic-5k ${mcool}::/resolutions/5000 --hic-10k ${mcool}::/resolutions/10000 --hi-50k ${mcool}::/resolutions/50000 -O ${out_prefix} -g hg38 --balance-type Raw --output-format full"

echo ${cmd} > "${out_prefix}.EagleC.cmd"

eval ${cmd}

