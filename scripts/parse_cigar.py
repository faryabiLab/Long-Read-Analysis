import re
import sys

def parse_cigar(cigar):
    # Returns dict: {op: total_count}
    parsed = re.findall(r'(\d+)([MIDNSHP=X])', cigar)
    summary = {}
    for count, op in parsed:
        summary[op] = summary.get(op, 0) + int(count)
    return summary

def summarize_sam_cigars(sam_file):
    print("QNAME\tREF_SEQ\tREF_ALIGN\tCIGAR\tM\tI\tD\tS\tH\t=")
    with open(sam_file) as f:
        for line in f:
            if line.startswith("@"):
                continue  # skip header
            cols = line.strip().split("\t")
            qname = cols[0]
            ref_seq = cols[2]
            ref_pos = cols[3]
            cigar = cols[5]
            if cigar == "*" or cigar == "":
                continue
            summary = parse_cigar(cigar)
            # Print summary table row: QNAME, CIGAR, counts for ops (0 if not present)
            print(f"{qname}\t{ref_seq}\t{ref_pos}\t"
                  f"{summary.get('M',0)}\t"
                  f"{summary.get('I',0)}\t"
                  f"{summary.get('D',0)}\t"
                  f"{summary.get('S',0)}\t"
                  f"{summary.get('H',0)}\t"
                  f"{summary.get('=',0)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python cigar_summary.py input.sam")
        sys.exit(1)
    summarize_sam_cigars(sys.argv[1])

