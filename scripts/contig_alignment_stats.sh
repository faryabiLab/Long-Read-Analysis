#!/usr/bin/env bash
set -euo pipefail

# contig_junction_view.sh
# Show query-oriented alignment blocks for a specific QNAME (contig/read).
# Prints TSV: qname  ref  pos  mapq  strand  qstart  qend  cigar [seq?]
#
# Usage:
#   contig_junction_view.sh -b alignments.bam -q contig_11 [-o out.tsv]
#                           [-m MIN_MAPQ] [--primary-only] [--include-seq] [--no-header]
#
# Notes:
# - qstart/qend are positions along the query (contig/read) computed from CIGAR,
#   accounting for strand and soft-clipping.
# - By default includes primary+secondary+supplementary (excludes unmapped).
#   Use --primary-only to keep only primary.
# - Requires: samtools, awk (gawk recommended for speed).

BAM=""
QNAME=""
OUT="-"
MINQ=0
PRIMARY_ONLY=0
INCLUDE_SEQ=0
HEADER=1

# --- arg parse ---
print_usage() {
  cat <<EOF
Usage: $(basename "$0") -b <bam> -q <qname> [options]

Options:
  -b <bam>           Input BAM/CRAM
  -q <qname>         Contig/read name (QNAME) to report (e.g., contig_11)
  -o <file>          Output TSV file (default: stdout)
  -m <INT>           Minimum MAPQ filter (default: 0)
  --primary-only     Keep only primary alignments (adds -F 260)
  --include-seq      Append the SEQ column as the last field (can be large)
  --no-header        Do not print header line
  -h, --help         Show this help
EOF
}

ARGS=("$@")
i=0
while [[ $i -lt ${#ARGS[@]} ]]; do
  a="${ARGS[$i]}"
  case "$a" in
    -b) BAM="${ARGS[++i]}";;
    -q) QNAME="${ARGS[++i]}";;
    -o) OUT="${ARGS[++i]}";;
    -m) MINQ="${ARGS[++i]}";;
    --primary-only) PRIMARY_ONLY=1;;
    --include-seq) INCLUDE_SEQ=1;;
    --no-header) HEADER=0;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $a" >&2; print_usage; exit 1;;
  esac
  ((i++))
done

[[ -n "$BAM" && -f "$BAM" ]] || { echo "ERROR: -b <bam> required and must exist" >&2; exit 1; }
[[ -n "$QNAME" ]] || { echo "ERROR: -q <qname> is required" >&2; exit 1; }

# samtools filters
SAMOPTS=(-h)
if [[ $PRIMARY_ONLY -eq 1 ]]; then
  SAMOPTS+=(-F 260)   # exclude unmapped (0x4), secondary (0x100)
else
  SAMOPTS+=(-F 4)     # exclude unmapped
fi
if [[ $MINQ -gt 0 ]]; then
  SAMOPTS+=(-q "$MINQ")
fi

# header
if [[ "$OUT" != "-" ]]; then exec >"$OUT"; fi
if [[ $HEADER -eq 1 ]]; then
  if [[ $INCLUDE_SEQ -eq 1 ]]; then
    echo -e "qname\tref\tpos\tmapq\tstrand\tqstart\tqend\tcigar\tseq"
  else
    echo -e "qname\tref\tpos\tmapq\tstrand\tqstart\tqend\tcigar"
  fi
fi

# stream and compute query-oriented coords
samtools view "${SAMOPTS[@]}" "$BAM" \
| awk -v Q="$QNAME" -v WITHSEQ="$INCLUDE_SEQ" 'BEGIN{OFS="\t"}
  function parse_cigar(c,    s, num, op, val, rest) {
    qlen=0; rlen=0; leadS=0; trailS=0;
    # leading S
    if (match(c, /^[0-9]+S/)) { s=substr(c,RSTART,RLENGTH); sub(/S/,"",s); leadS = s+0; }
    # trailing S
    if (match(c, /[0-9]+S$/)) { s=substr(c,RSTART,RLENGTH); sub(/S/,"",s); trailS = s+0; }
    # walk number+op pairs
    s = c
    while (match(s, /([0-9]+)([MIDNSHP=X])/)) {
      num = substr(s, RSTART, RLENGTH-1) + 0
      op  = substr(s, RSTART+RLENGTH-1, 1)
      if (op=="M" || op=="I" || op=="=" || op=="X") qlen += num
      if (op=="M" || op=="D" || op=="N" || op=="=" || op=="X") rlen += num
      s = substr(s, RSTART+RLENGTH)
    }
  }
  function hasbit(v,b){ return and(v,b) }
  $1==Q {
    flag=$2; rname=$3; pos=$4; mapq=$5+0; cig=$6; seq=$10
    strand = (hasbit(flag,16) ? "-" : "+")
    parse_cigar(cig)
    read_len = qlen + leadS + trailS
    if (strand=="+") {
      qstart = leadS
      qend   = qstart + qlen
    } else {
      qend   = read_len - leadS
      qstart = qend - qlen
    }
    if (WITHSEQ) {
      print Q, rname, pos, mapq, strand, qstart, qend, cig, seq
    } else {
      print Q, rname, pos, mapq, strand, qstart, qend, cig
    }
  }
' | sort -S 1G -t $'\t' -k6,6n

