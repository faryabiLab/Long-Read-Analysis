#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $0 -b aln.bam -f reads.fastq.gz -o out_prefix \\
     --left-chr chrL --left-pos POSL --left-strand [+|-] --left-win WINL \\
     --right-chr chrR --right-pos POSR --right-strand [+|-] --right-win WINR \\
     [--threads 16]

Definitions:
  - 5' (left-hand) window = upstream of left breakpoint w.r.t. LEFT strand.
  - 3' (right-hand) window = downstream of right breakpoint w.r.t. RIGHT strand.

Examples:
  # Both breakpoints on + strand: 5' = [pos-WIN, pos-1], 3' = [pos+1, pos+WIN]
  # Left on -, right on + : 5' (left, -) = [pos+1, pos+WIN]; 3' (right, +) = [pos+1, pos+WIN]

Outputs:
  out_prefix.left.bed / right.bed
  out_prefix.IDs_left.txt / IDs_right.txt / IDs_split.txt / IDs_union.txt
  out_prefix.union.fastq.gz
  out_prefix.windows.union.sorted.bam(.bai)   # IGV-ready
EOF
}

# ---------------- args ----------------
bam="" ; fq="" ; out="" ; threads=16
LCHR=""; LPOS=""; LSTR=""; LWIN=""
RCHR=""; RPOS=""; RSTR=""; RWIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b) bam="$2"; shift 2;;
    -f) fq="$2"; shift 2;;
    -o) out="$2"; shift 2;;
    --threads) threads="$2"; shift 2;;
    --left-chr) LCHR="$2"; shift 2;;
    --left-pos) LPOS="$2"; shift 2;;
    --left-strand) LSTR="$2"; shift 2;;
    --left-win) LWIN="$2"; shift 2;;
    --right-chr) RCHR="$2"; shift 2;;
    --right-pos) RPOS="$2"; shift 2;;
    --right-strand) RSTR="$2"; shift 2;;
    --right-win) RWIN="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

[[ -f "$bam" && -f "$fq" && -n "$out" ]] || { echo "ERROR: missing -b/-f/-o"; usage; exit 1; }
[[ -n "$LCHR" && -n "$LPOS" && -n "$LSTR" && -n "$LWIN" ]] || { echo "ERROR: missing left params"; usage; exit 1; }
[[ -n "$RCHR" && -n "$RPOS" && -n "$RSTR" && -n "$RWIN" ]] || { echo "ERROR: missing right params"; usage; exit 1; }
[[ "$LSTR" == "+" || "$LSTR" == "-" ]] || { echo "ERROR: --left-strand must be + or -"; exit 1; }
[[ "$RSTR" == "+" || "$RSTR" == "-" ]] || { echo "ERROR: --right-strand must be + or -"; exit 1; }

# ----------- helpers -----------
# Build 1-based inclusive intervals for upstream/downstream given strand and window
# For + strand: upstream=[pos-W, pos-1], downstream=[pos+1, pos+W]
# For - strand: upstream=[pos+1, pos+W], downstream=[pos-W, pos-1]   (because genomic coords run opposite to transcript 5'→3')
mk_upstream() {
  local pos="$1" str="$2" win="$3" start end
  if [[ "$str" == "+" ]]; then
    start=$(( pos - win )); (( start < 1 )) && start=1
    end=$(( pos - 1 ))
  else
    start=$(( pos + 1 ))
    end=$(( pos + win ))
  fi
  echo "$start $end"
}
mk_downstream() {
  local pos="$1" str="$2" win="$3" start end
  if [[ "$str" == "+" ]]; then
    start=$(( pos + 1 ))
    end=$(( pos + win ))
  else
    start=$(( pos - win )); (( start < 1 )) && start=1
    end=$(( pos - 1 ))
  fi
  echo "$start $end"
}

# Left: take UPSTREAM (5') of left breakpoint
read LSTART LEND < <(mk_upstream "$LPOS" "$LSTR" "$LWIN")
# Right: take DOWNSTREAM (3') of right breakpoint
read RSTART REND < <(mk_downstream "$RPOS" "$RSTR" "$RWIN")

# Guard against inverted/empty ranges
if (( LEND < LSTART )); then tmp="$LSTART"; LSTART="$LEND"; LEND="$tmp"; fi
if (( REND < RSTART )); then tmp="$RSTART"; RSTART="$REND"; REND="$tmp"; fi

echo "# Left (5'):  ${LCHR}:${LSTART}-${LEND}   [strand ${LSTR}, win ${LWIN}]" >&2
echo "# Right (3'): ${RCHR}:${RSTART}-${REND}   [strand ${RSTR}, win ${RWIN}]" >&2

# BED needs 0-based start, 1-based end:
echo -e "${LCHR}\t$((LSTART-1))\t${LEND}"  >  "${out}.left.bed"
echo -e "${RCHR}\t$((RSTART-1))\t${REND}"  >  "${out}.right.bed"
cat "${out}.left.bed" "${out}.right.bed" > "${out}.windows.bed"

# ----------- collect IDs -----------
echo "[1] IDs in left 5' window..."
samtools view -@ "$threads" -M "$bam" "${LCHR}:${LSTART}-${LEND}" \
  | cut -f1 | sort -u > "${out}.IDs_left.txt"

echo "[2] IDs in right 3' window..."
samtools view -@ "$threads" -M "$bam" "${RCHR}:${RSTART}-${REND}" \
  | cut -f1 | sort -u > "${out}.IDs_right.txt"

echo "[3] Intersect (split) and union..."
comm -12 "${out}.IDs_left.txt" "${out}.IDs_right.txt" > "${out}.IDs_split.txt"
cat "${out}.IDs_left.txt" "${out}.IDs_right.txt" | sort -u > "${out}.IDs_union.txt"

# ----------- subset FASTQ for assembly -----------
echo "[4] Subset FASTQ (union) for local assembly..."
seqtk subseq "$fq" "${out}.IDs_union.txt" | gzip -c > "${out}.union.fastq.gz"

# ----------- optional BAM (restricted) -----------
echo "[5] Build IGV-ready BAM limited to windows + union IDs..."
samtools view -@ "$threads" -M -L "${out}.windows.bed" -N "${out}.IDs_union.txt" -b "$bam" \
  | samtools sort -@ "$threads" -o "${out}.windows.union.sorted.bam"
samtools index "${out}.windows.union.sorted.bam"

echo "[DONE]"
echo "  Windows:"
echo "    Left  (5'): ${LCHR}:${LSTART}-${LEND} (strand ${LSTR})"
echo "    Right (3'): ${RCHR}:${RSTART}-${REND} (strand ${RSTR})"
echo "  IDs: ${out}.IDs_left.txt  ${out}.IDs_right.txt  ${out}.IDs_split.txt  ${out}.IDs_union.txt"
echo "  FASTQ: ${out}.union.fastq.gz"
echo "  BAM:   ${out}.windows.union.sorted.bam(.bai)"

