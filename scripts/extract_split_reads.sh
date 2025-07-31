#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome


USAGE="Usage: $0 -b <bam file> -w <window size> -b1 <5' side of breakpoint, i.e. chr11:690000> -b2 <3' side of breakpoint> "

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
threads=48
window=1000000
output_prefix=""
b1=""
b2=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-b | --bam )
			ref="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output_prefix )
			out_prefix="$2"
			shift 2
			;;
		-w | --window )
			window="$2"
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

# Compute window coordinates
half_window=$((window / 2))
start1=$((pos1 - half_window))
end1=$pos1

start2=$pos2
end2=$((pos2 + half_window))

# Final command
cmd=$(cat <<EOF
# Extract reads from window 1
samtools view -F 4 ${bam} ${chr1}:${start1}-${end1} | cut -f1 | sort | uniq > ${out_prefix}_chr1_reads.txt

# Extract reads from window 2
samtools view -F 4 ${bam} ${chr2}:${start2}-${end2} | cut -f1 | sort | uniq > ${out_prefix}_chr2_reads.txt

# Intersect to get split reads
comm -12 ${out_prefix}_chr1_reads.txt ${out_prefix}_chr2_reads.txt > ${out_prefix}_split_reads.txt

# Extract all alignments for split reads
samtools view -h ${bam} | grep -E "^@|$(paste -sd'|' ${out_prefix}_split_reads.txt)" | samtools view -Sb - > ${out_prefix}_split_reads.bam

# Optional: convert to SAM for inspection
samtools view ${out_prefix}_split_reads.bam > ${out_prefix}_split_reads.sam
EOF
)

# Log and run
echo "$cmd" > "${out_prefix}.cmd"
bash -c "$cmd"
