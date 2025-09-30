#!/bin/bash
# Annotate genes on contig using Liftoff
# Parameters:
ref=""		# PASSED VIA CLI
assem=""	# PASSED VIA CLI
gtf=""		# PASSED VIA CLI
out_prefix=""	# PASSED VIA CLI
threads=24

USAGE="Usage: $0 -f <reference fasta> -a <assembly fasta> -g <gtf file> -o <output prefix>"

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
		-g | --gtf )
			gtf="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

assem_full=$(realpath "${assem}")
ref_full=$(realpath "${ref}")
gtf_full=$(realpath "${gtf}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}" <<EOF
#!/bin/bash
# ========================================
# Run on: $(hostname)
# Run by: $(whoami)
# Environment: $(basename "$CONDA_PREFIX")
# Run in directory $(pwd)
# ========================================

liftoff -g ${gtf_full} ${assem_full} ${ref_full} -o ${out_prefix}.gtf
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"

