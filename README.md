# Long-Read-Analysis
## Usage
Install [conda](https://www.anaconda.com/docs/getting-started/miniconda/install#linux-2) and activate the appropriate environment via:
```
conda env create -f ont-env.yml
```

## Environment
Install the conda environment via `conda env create -f ont-env.yml`

## Scripts
This section highlights the analysis scripts in this repository, broken down by analysis type.
#### Quality Control / Filtering
| Script  | Description |
| ------------- | ------------- |
| `scripts/seqkit_stats.sh`  | Simple wrapper of `seqkit stats` command to get assembly statistics like average length and N50.  |
| `scripts/filter_reads_length.sh`  | Wraps `FiltLong` to filter out reads in the bottom 10% by length.  |
| `scripts/nanoplot_run.sh` | Use `NanoPlot` to generate summary statistics for `fastq` |
| `scripts/porechop_trim.sh` | Wraps `porechop` for adapter trimming. |
#### Herro Read Error Correction
| Script  | Description |
| ------------- | ------------- |
| `scripts/herro_preprocess.sh` | Runs the `herro` pipeline preprocessing step. | 
| `scripts/herro_batch_align.sh` | Runs the `herro` batch alignment workflow. |
| `scripts/herro_correct.sh` | Runs the `herro` read error correction pipeline. |
#### Alignment
| Script  | Description |
| ------------- | ------------- |
| `scripts/align_ont_dorado.sh`  | Align ONT `fastq` with `dorado align`. |
| `scripts/align_contigs_to_ref.sh`  | Wraps `minimap2`, used to align assembled contigs to reference sequence.  |
#### Assembly
| Script  | Description |
| ------------- | ------------- |
| `scripts/hifiasm_assembly.sh`  | Assemble a `fastq` using `hifiasm`. |
| `scripts/flye_assembly.sh` | Assemble a `fastq` using `flye`. |
| `scripts/extract_split_reads.sh`  | Series of `samtools` operations to extract split reads (reads that map to 2 different reference sequences.  |
| `scripts/extract_bnd_reads.sh` | Extract split reads and reads providing context in flanking regions. |
| `scripts/extract_spanning_contigs.sh` | After aligning assembled contigs to a reference genome with `align_contigs_to_ref.sh`, extract contigs that align to multiple chromosomes. |

| Script  | Description |
| ------------- | ------------- |
| [D-GENIES](https://dgenies.toulouse.inra.fr/run) | Not a script; UI used for generating dotplots from paired `fasta` |
#### Structural Variant Discovery
| Script  | Description |
| ------------- | ------------- |
| `scripts/eaglec_bnds.sh` | Use `EagleC` to find structural variants from a 3C matrix in `.mcool` format. |
#### Utilities / Miscellaneous
| Script  | Description |
| ------------- | ------------- |
| `scripts/parse_cigar.py` | Parse and plot CIGAR strings within a `sam` file. |
| `scripts/alignment_summarry.sh` | Quickly get alignments of a contig after being aligned to a reference genome. |
| `sctipts/make_bnd_seq.sh`  |  Subsequence 2 sequences from a reference fasta file as given coordinates, returning them as separate `fasta` entries in a single file. |
| `sctipts/make_bnd_seq_concat.sh`  |  Concatenate 2 sequences from a reference fasta file as given coordinates, returning them as a single `fasta` entry. |
#### Project Structure / Directory Setup
| Script  | Description |
| ------------- | ------------- |
| `project_structure/make_dir_structure.sh` | Create the standardized production data folder structure for these analyses. |
| `project_structure/generator.py` | Set up the project directory structure with additional metadata and logging. |




