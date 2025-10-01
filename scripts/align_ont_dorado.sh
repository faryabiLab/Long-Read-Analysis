#!/bin/bash
# Align ONT data with Dorado


USAGE="Usage: $0 -f <fastq to align> -a <assembly fasta> -o <output prefix> -p <dorado path>"

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
assem=""
threads=24
out_prefix=""
path=""

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
		-a | --assembly_fasta )
			assem="$2"
			shift 2
			;;
		-p | --dorado-path )
			path="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

fastq_full=$(realpath "${fastq}")
assem_full=$(realpath "${assem}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename "$0")
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}"<<EOF
#!/bin/bash
# ========================================
# Run on: $(hostname)
# Run by: $(whoami)
# Environment: $(basename "$CONDA_PREFIX")
# Run in directory $(pwd)
# Date: $(date +"%m/%d/%Y")
# Time: $(date +"%I:%M %p")
# ========================================

${path}/dorado aligner --output-dir . --emit-summary --threads ${threads} --mm2-opts '-Y' ${assem_full} ${fastq_full}
EOF

chmod +x "${script_name}"

echo "Wrote executable script: ${script_name}"

./"${script_name}"

