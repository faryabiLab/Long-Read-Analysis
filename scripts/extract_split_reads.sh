#!/bin/bash
# Extract alignned reads overlapping both intervals b1 and b2, defined by a window size
# Parameters
bam=""			# PASSED VIA CLI
window=1000000		# PASSED VIA CLI
b1=""			# PASSED VIA CLI
b2=""			# PASSED VIA CLI
output_prefix=""	# PASSED VIA CLI
threads=24		# PASSED VIA CLI

USAGE="Usage: $0 -b <bam file> -o <output prefix> -w <window size> -b1 <5' side of breakpoint, i.e. chr11:690000> -b2 <3' side of breakpoint> "

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

# Compute window coordinates
half_window=$((window / 2))
start1=$((pos1 - half_window))
end1=$pos1

start2=$pos2
end2=$((pos2 + half_window))

bam_full=$(realpath "${bam}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"


echo "Extracting reads from ${chr1}:${start1}-${end1} and ${chr2}:${start2}-${end2}"

cat > "$script_name" <<EOF
#!/bin/bash
# ========================================
# Run on: $(hostname)
# Run by: $(whoami)
# Environment: $(basename "$CONDA_PREFIX")
# Run in directory $(pwd)
# ========================================

echo '1: Extract ${chr1}:${start1}-${end1} from ${bam_full}'
samtools view -@ ${threads} -F 4 ${bam_full} ${chr1}:${start1}-${end1} | cut -f1 | sort | uniq > ${out_prefix}_${chr1}_reads.txt

echo '2: Extract ${chr2}:${start2}-${end2} from ${bam_full}'
samtools view -@ ${threads} -F 4 ${bam_full} ${chr2}:${start2}-${end2} | cut -f1 | sort | uniq > ${out_prefix}_${chr2}_reads.txt

echo '3: Find common read names'
cat ${out_prefix}_${chr1}_reads.txt ${out_prefix}_${chr2}_reads.txt | sort -u > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.txt

echo '4: Extract header from ${bam_full}'
samtools view -@ 4 -H ${bam_full} > ${out_prefix}_header.sam

echo '5: Extract the split read names from ${bam_full}'
samtools view -@ ${threads} ${bam_full} | grep -wFf ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.txt > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam

echo '6: Create final bam with header and ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam'
cat ${out_prefix}_header.sam ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.sam | samtools view -@ ${threads} -Sb - > ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.bam

echo '7: Convert final bam to fastq ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.fastq'
samtools fastq -o ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.fastq ${out_prefix}_all_window_reads_${chr1}-${chr2}_${window}.bam
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"

