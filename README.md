This repository stores conda environment manifests and scripts necessary for Whole-Genome Long Read Sequencing data, specifically Oxford Nanopore Technologies (ONT).

## Environments
Use `conda` to set up compute environments for the scripts below. \
Available environments:
| Environment  | Description |
| ------------- | ------------- |
| `envs/ont-env.yml` | Long read analysis-specific software |
| `envs/hic_process.yml` | HiC/MicroC alignment and processing with Juicer. |
| `envs/eaglec.yml` | Structural variant detection from HiC contact matrices with EagleC. |

Install and activate any of these with the command `conda env create -f <env.yml>`.

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
| `scripts/extract_bnd_reads_noWindow.sh` | Extract split reads by specifying chromosomal start and end coordinates, no window needed. |
| `scripts/extract_spanning_contigs.sh` | After aligning assembled contigs to a reference genome with `align_contigs_to_ref.sh`, extract contigs that align to multiple chromosomes. |
| `scripts/ragtag_scaffold.sh` | Scaffold conntigs together with RagTag. |

| Script  | Description |
| ------------- | ------------- |
| [D-GENIES](https://dgenies.toulouse.inra.fr/run) | Not a script; UI used for generating dotplots from paired `fasta` |
#### Structural Variant Discovery
| Script  | Description |
| ------------- | ------------- |
| `scripts/eaglec_bnds.sh` | Use `EagleC` to find structural variants from a 3C matrix in `.mcool` format. |
| `scripts/spectre_cnv.sh` | Calculate & plot copy number information with `spectre` |
#### Assembly Annotation
| Script  | Description |
| ------------- | ------------- |
| `scripts/liftoff_gene_annotations.sh` | USe a reference `.gtf` and `.fasta` to annotate gene sequences in assembly `.fasta` |
#### Utilities / Miscellaneous
| Script  | Description |
| ------------- | ------------- |
| `scripts/parse_cigar.py` | Parse and plot CIGAR strings within a `sam` file. |
| `scripts/alignment_summarry.sh` | Quickly get alignments of a contig after being aligned to a reference genome. |
| `sctipts/make_bnd_seq.sh`  |  Subsequence 2 sequences from a reference fasta file as given coordinates, returning them as separate `fasta` entries in a single file. |
| `sctipts/make_bnd_seq_concat.sh`  |  Concatenate 2 sequences from a reference fasta file as given coordinates, returning them as a single `fasta` entry. |
| `scripts/gfa_to_fasta.sh` | Convert a `gfa` file to a `fasta` file with `gfatools` |
## Browsers
**[JBrowse2](https://jbrowse.org/jb2/)**
* Upload `bam` and `.bai` to view long-read alignnments.



