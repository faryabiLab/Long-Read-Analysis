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
* `scripts/hifiasm_assembly.sh`: Assemble a `fastq` using `hifiasm`
* `scripts/align_contigs_to_ref.sh`: Wraps `minimap2`, used to align assembled contigs to reference sequence.
* `scripts/extract_split_reads.sh`: Series of `samtools` operations to extract split reads (reads that map to 2 different reference sequences).
* `scripts/seqkit_stats.sh`: Simple wrapper of `seqkit stats` command to get assembly statistics like average length and N50.

#### Utilities
* `scripts/parse_cigar.py`: Parse and plot CIGAR strings within a `sam` file.
* `project_structure/make_dir_structure.sh`: Simply create the standardized production data folder structure for these analyses.

