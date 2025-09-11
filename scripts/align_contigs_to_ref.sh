#!/bin/bash
# Align, convert, and sort assembled contigs to refrence genome
# Parameters:
preset="asm5"
softclip="-Y"
threads=24
ref="" 		# PASSED ON CLI
assem="" 	# PASSED ON CLI
out_prefix=""	# PASSED ON CLI

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

function archive_run()
{
	stamp=$(date +"%Y%m%d_%H%M%S")
	base_name=$(basename $0)
	base="${base_name%.*}"

	out="${base}_${stamp}.sh"

	cp "$0" "${out}"
	echo "Archived script $0 to $out."
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
		-* | --* )
			print_usage_exit $1
			;;
	esac
done

ref_full=$(realpath "${ref}")
assem_full=$(realpath "${assem}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

# Write the command into a new script
cat > "$script_name" <<EOF
#!/bin/bash
minimap2 -ax asm5 -Y -t ${threads} ${ref_full} ${assem_full} | samtools view -bS - | samtools sort -@ ${threads} -o ${out_prefix}.sorted.bam
EOF

chmod +x "$script_name"

echo "Wrote executable script: $script_name"

# Run the command immediately
./"$script_name"


# and if i don't see ya, good afternoon, good evening, and goodnight.
