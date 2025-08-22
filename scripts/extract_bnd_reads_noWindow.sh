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
threads=24
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
samtools view -@ ${threads} -F 4 -b $bam ${chr1}:${start1}-${end1} > tmp_${chr1}_aln.bam 

echo '2: Extract ${chr2}:${start2}-${end2} from ${bam}'
samtools view -@ ${threads} -F 4 -b $bam ${chr2}:${start2}-${end2} > tmp_${chr2}_aln.bam

echo '3: Merge temp bams'
samtools merge -@ ${threads} -o ${out_prefix}.bam tmp_${chr1}_aln.bam tmp_${chr2}_aln.bam

echo '4: Convert final bam to fastq ${out_prefix}_${chr1}${chr2}.fastq'
samtools fastq  ${out_prefix}.bam > ${out_prefix}_${chr1}${chr2}.fastq

echo '5: gzip result fastq'
pigz ${out_prefix}_${chr1}${chr2}.fastq

rm tmp_${chr1}_aln.bam tmp_${chr2}_aln.bam
"

# Log and run
echo "$cmd" > "${out_prefix}.extract_bnd_reads_noWindow.cmd"
eval "${cmd}"
