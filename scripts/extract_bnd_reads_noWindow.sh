#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -b <bam file> -o <output prefix> -b1 <5' side of breakpoint, i.e. chr11:690000-700000> -b2 <3' side of breakpoint> "

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

bam=""
threads=1
window=1000000
output_prefix=""
b1=""
b2=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-b | --bam )
			bam="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output_prefix )
			out_prefix="$2"
			shift 2
			;;
		-b1 | --breakpoint1 )
			b1="$2"
			shift 2
			;;
		-b2 | --breakpoint2 )
			b2="$2"
			shift 2
			;;
		-t | --threads )
			threads="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

# Parse breakpoints
chr1=$(echo $b1 | cut -d: -f1)
pos1=$(echo $b1 | cut -d: -f2)
chr2=$(echo $b2 | cut -d: -f1)
pos2=$(echo $b2 | cut -d: -f2)

start1=$(echo $pos1 | cut -d- -f1)
end1=$(echo $pos1 | cut -d- -f2)
start2=$(echo $pos2 | cut -d- -f1)
end2=$(echo $pos2 | cut -d- -f2)

echo "Extracting reads from ${chr1}:${start1}-${end1} and ${chr2}:${start2}-${end2}"

cmd="
echo '1: Extract ${chr1}:${start1}-${end1} from ${bam}'
samtools view -@ ${threads} -F 4 $bam ${chr1}:${start1}-${end1} | cut -f1 | sort | uniq > ${out_prefix}_${chr1}_reads.txt

echo '2: Extract ${chr2}:${start2}-${end2} from ${bam}'
samtools view -@ ${threads} -F 4 $bam ${chr2}:${start2}-${end2} | cut -f1 | sort | uniq > ${out_prefix}_${chr2}_reads.txt

echo '3: Find common read names'
cat ${out_prefix}_${chr1}_reads.txt ${out_prefix}_${chr2}_reads.txt | sort -u > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.txt

echo '4: Extract header from ${bam}'
samtools view -@ 4 -H ${bam} > ${out_prefix}_header.sam

echo '5: Extract the split read names from ${bam}'
samtools view -@ ${threads} ${bam} | grep -wFf ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.txt > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam

echo '6: Create final bam with header and ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam'
cat ${out_prefix}_header.sam ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam | samtools view -@ ${threads} -Sb - > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.bam

echo '7: Convert final bam to fastq ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.fastq'
samtools fastq ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.fastq ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.bam
"

# Log and run
echo "$cmd" > "${out_prefix}.extract_bnd_reads.cmd"
eval "${cmd}"
