#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -g <gfa to convert> -o <output prefix>"

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
threads=48
out_prefix=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-g | --gfa )
			ref="$2"
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

cmd="gfatools gfa2fa ${gfa} > ${out_prefix}.fasta"
echo ${cmd} > "${out_prefix}.gfa_to_fasta.cmd"

eval ${cmd}

