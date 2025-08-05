# Long-Read-Analysis
## Usage
Install [conda](https://www.anaconda.com/docs/getting-started/miniconda/install#linux-2) and activate the appropriate environment via:
```
conda env create -f ont-env.yml
```

## Environments
Install an environment via `conda env create -f <env file>`
* `ont-env`: Software needed for all ONT data analysis.
* `hic-env`: Software needed for Hi-C/Micro-C analysis.

## Scripts
#### Wrappers
Scripts simply wrapping common operations & logging the command. Run the script with no parameters to see usage.
* `hifiasm_assembly.sh`: Assemble a `fastq` using `hifiasm`
* `align_contigs_to_ref.sh`: Wraps `minimap2`, used to align assembled contigs to reference sequence.
* `extract_split_reads.sh`: Series of `samtools` operations to extract split reads (reads that map to 2 different reference sequences).
* `seqkit_stats.sh`: Simple wrapper of `seqkit stats` command to get assembly statistics like average length and N50.

#### Utilities
* `parse_cigar.py`: Parse and plot CIGAR strings within a `sam` file.

