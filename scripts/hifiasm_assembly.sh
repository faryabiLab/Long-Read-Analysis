#!/bin/bash
# Assemble ONT reads with HiFiasm
# Parameters:
fastq=""	# PASSED VIA CLI
out_prefix=""	# PASSED VIA CLI
threads=24

USAGE="Usage: $0 -f <fastq> -o <output prefix>"

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

fastq_full=$(realpath "${fastq}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}" << EOF
#!/bin/bash
# ========================================
# Run on: $(hostname)
# Run by: $(whoami)
# Environment: $(basename "$CONDA_PREFIX")
# Run in directory $(pwd)
# ========================================

hifiasm -o ${out_prefix}.asm --ont -t ${threads} ${fastq_full}
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"
