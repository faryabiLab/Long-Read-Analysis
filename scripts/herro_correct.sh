#!/bin/bash
# Run Herro preprocessing script 

batch_dir=""
model_path=""
preprocessed_reads=""
batch_size=16
threads=4
out_prefix=""
dir=""
device=0

USAGE="Usage: $0 -d <batch align dir> -p <preprocessed reads fastq> -m <path to model> -b <batch size> -o <output prefix>"

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
		-d | --dir-batch-align )
			batch_dir="$2"
			shift 2 # Shift past both argument and value
			;;
		-p | --preproessed-reads )
			preprocessed_reads="$2"
			shift 2
			;;
		-m | --model-path )
			model_path="$2"
			shift 2
			;;
		-b | --batch-size )
			batch_size="$2"
			shift 2
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

fastq_full=$(realpath "${fastq}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}" <<EOF
#!/bin/bash
# ========================================
# Run on: $(hostname)
# Run by: $(whoami)
# Run in directory $(pwd)
# ========================================

herro inference --read-alns ${batch_dir} -t ${threads} -d ${device} -m ${model_path} -b ${batch_size} ${preprocessed_reads} ${out_prefix}.fasta
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"

