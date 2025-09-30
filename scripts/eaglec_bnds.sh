#!/bin/bash
# Run EagleC on a .mcool 3C matrix.
# Parameters:
threads=24
mcool="" 	# PASSED VIA CLI
out_prefix=""	# PASSED VIA CLI

USAGE="Usage: $0 -m <mcool file> -o <output prefix>"

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
		-m | --mcool )
			mcool="$2"
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

mcool_full=$(realpath "${mcool}")

stamp=$(date +"%Y%m%d_%H%M%S")
base_name=$(basename $0)
base="${base_name%.*}"

script_name="${base}_${stamp}.sh"

cat > "$script_name" <<EOF
#!/bin/bash
# Run on: $(hostname)
predictSV --hic-5k ${mcool_full}::/resolutions/5000 --hic-10k ${mcool_full}::/resolutions/10000 --hic-50k ${mcool_full}::/resolutions/50000 -O ${out_prefix} -g hg38 --balance-type Raw --output-format full
EOF

chmod +x "$script_name"

./"$script_name"

