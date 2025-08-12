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
This section highlights the analysis scripts in this repository, broken down by analysis type.
#### Quality Control / Filtering
| Script  | Description |
| ------------- | ------------- |
| `scripts/seqkit_stats.sh`  | Simple wrapper of `seqkit stats` command to get assembly statistics like average length and N50.  |
| `scripts/filter_reads_length.sh`  | Wraps `FiltLong` to filter out reads in the bottom 10% by length.  |
| `scripts/nanoplot_run.sh` | Use `NanoPlot` to generate summary statistics for `fastq` |
| `scripts/porechop_trim.sh` | Wraps `porechop` for adapter trimming. |
#### Alignment
| Script  | Description |
| ------------- | ------------- |
| `scripts/align_ont_dorado.sh`  | Align ONT `fastq` with `dorado align`. |
| `scripts/align_contigs_to_ref.sh`  | Wraps `minimap2`, used to align assembled contigs to reference sequence.  |
#### Assembly
| Script  | Description |
| ------------- | ------------- |
| `scripts/hifiasm_assembly.sh`  | Assemble a `fastq` using `hifiasm`. |
| `scripts/extract_split_reads.sh`  | Series of `samtools` operations to extract split reads (reads that map to 2 different reference sequences.  |
#### Herro Read Error Correction
| Script  | Description |
| ------------- | ------------- |
| `scripts/herro_preprocess.sh` | Runs the `herro` pipeline preprocessing step. | 
| `scripts/herro_batch_align.sh` | Runs the `herro` batch alignment workflow. |
| `scripts/herro_correct.sh` | Runs the `herro` read error correction pipeline. |
#### Utilities / Miscellaneous
| Script  | Description |
| ------------- | ------------- |
| `scripts/parse_cigar.py` | Parse and plot CIGAR strings within a `sam` file. |
#### Project Structure / Directory Setup
| Script  | Description |
| ------------- | ------------- |
| `project_structure/make_dir_structure.sh` | Create the standardized production data folder structure for these analyses. |
| `project_structure/generator.py` | Set up the project directory structure with additional metadata and logging. |




