import re
import sys
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def parse_cigar(cigar):
    # Returns dict: {op: total_count}
    parsed = re.findall(r'(\d+)([MIDNSHP=X])', cigar)
    summary = {}
    for count, op in parsed:
        summary[op] = summary.get(op, 0) + int(count)
    return summary

def parse_cigar_segments(cigar):
    return [(op, int(length)) for length, op in re.findall(r'(\d+)([MIDNSHP=X])', cigar)]

def summarize_sam_cigars(sam_file):
    print("QNAME\tREF_SEQ\tREF_ALIGN\tCIGAR\tPARSED")
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
            parsed = parse_cigar_segments(cigar)  # ordered list of tuples
            plot_cigar(parsed, qname, ref_seq, ref_pos)
            parsed_str = " ".join([f"{n}{op}" for op, n in parsed])
            print(f"{qname}\t{ref_seq}\t{ref_pos}\t{parsed_str}")

def plot_cigar(cigar_tuples, qname, ref_seq, ref_pos, ax=None):
    color_map = {
        'M': 'green',
        'I': 'blue',
        'D': 'red',
        'S': 'orange',
        'H': 'gray',
        '=': 'lime',
        'X': 'purple',
        'N': 'cyan',
        'P': 'pink'
    }
    if ax is None:
        fig, ax = plt.subplots(figsize=(8, 1.2))  # Thin figure

    start = 0
    for op, length in cigar_tuples:
        ax.barh(0, width=length, left=start, color=color_map.get(op, 'black'),
                edgecolor=None, height=0.12)
        start += length

    # Optional: comment out if you want NO legend at all
    legend_patches = [mpatches.Patch(color=color, label=op) for op, color in color_map.items()]
    ax.legend(handles=legend_patches, bbox_to_anchor=(1.05, 1), loc='upper left', fontsize='small', frameon=False)

    ax.set_yticks([])
    ax.set_frame_on(False)
    ax.get_yaxis().set_visible(False)
    ax.set_xlabel("Read coordinate", fontsize=9)
    ax.set_title(f"{qname}, {ref_seq}:{ref_pos}", fontsize=10)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    plt.tight_layout()
    plt.savefig(f"{qname}_{ref_seq}_{ref_pos}_CIGAR-plot.png", bbox_inches='tight', dpi=150)
    plt.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python cigar_summary.py input.sam")
        sys.exit(1)
    summarize_sam_cigars(sys.argv[1])

