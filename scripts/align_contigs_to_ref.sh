#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -f <reference fasta> -a <assembly fasta> -o <output prefix>"

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
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

cmd="minimap2 -ax asm5 -Y -t ${threads} ${ref} ${assem} | samtools view -bS - | samtools sort -@ ${threads} -o ${out_prefix}.sorted.bam"
echo ${cmd} > "${out_prefix}.align_assembly.cmd"

eval ${cmd}

