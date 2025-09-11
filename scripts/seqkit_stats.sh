#!/bin/bash
# Get assembly statistics with seqkit
# Parameters:
fasta=""	# PASSED VIA CLI
out_prefix=""	# PASSED VIA CLI

USAGE="Usage: $0 -f <fasta> -o <out prefix>"

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
			fasta="$2"
			shift 2 # Shift past both argument and value
			;;
		-o | --output )
			out_prefix="$2"
			shift 2
			;;
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

fasta_full=$(realpath "${fasta}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "${script_name}" <<EOF
#!/bin/bash
seqkit stats ${fasta_full} --all > ${out_prefix}.stats
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"
