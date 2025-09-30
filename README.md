This repository stores conda environment manifests and scripts necessary for Whole-Genome Long Read Sequencing data, specifically Oxford Nanopore Technologies (ONT).

## Environments
Use `conda` to set up compute environments for the scripts below. \
Available environments:
| Environment  | Description | Usage |
| ------------- | ------------- | ------- |
| `envs/ont-env.yml` | Long read analysis-specific software | ONT-specific analyses.
| `envs/hic_process.yml` | HiC/MicroC alignment and processing with Juicer. | HiC alignment and processing
| `envs/eaglec.yml` | Structural variant detection from HiC contact matrices with EagleC. | SV detection via HiC matrix.
| `envs/herro/Dockerfile` | Herro read correction (Docker container) | GPU-enabled read error correction with Herro

Install and activate any of the conda environments with:
```
conda env create -f <env.yml>
conda activate <env>
```
**Note:** The name of each environment is the filename without `.yml`.
Build the herro Docker conainer:
```
cd envs/herro
docker built --name herro:latest .
```
## Scripts
This section highlights the analysis scripts in this repository, broken down by analysis type.
### Logging
Upon execution, each of the below scripts will generate an executable script in the directory from which it was run containing only the command(s) run, named as `{script}_{date}_{time}.sh` (date is `YYYYMMDD`, time is `HHMMSS` in 24hr time). These generated scripts can be run as-is with no parameters to reproduce its result, i.e. via `./{script}_{date}_{time}.sh`.
#### Quality Control / Filtering
| Script  | Description | Tool(s) | Environment 
| ------------- | ------------- | ------- | ----- |
| `scripts/seqkit_stats.sh`  | Simple wrapper of `seqkit stats` command to get assembly statistics like average length and N50.  | `seqkit` | `ont-env`
| `scripts/filter_reads_length.sh`  | Wraps `FiltLong` to filter out reads in the bottom 10% by length.  | `FiltLong` | `ont-env`
| `scripts/nanoplot_run.sh` | Use `NanoPlot` to generate summary statistics for `fastq` | `NanoPlot` | `ont-env`
| `scripts/porechop_trim.sh` | Wraps `porechop` for adapter trimming. | `porechop` | `ont-env`
#### Herro Read Error Correction
| Script  | Description | Environment 
| ------------- | ------------- | ----- |
| `scripts/herro_preprocess.sh` | Runs the `herro` pipeline preprocessing step. | `herro/Dockerfile`
| `scripts/herro_batch_align.sh` | Runs the `herro` batch alignment workflow. | `herro/Dockerfile`
| `scripts/herro_correct.sh` | Runs the `herro` read error correction pipeline. | `herro/Dockerfile`
#### Alignment
| Script  | Description | Tool(s) | Environment 
| ------------- | ------------- | ---------- | ----- |
| `scripts/align_ont_dorado.sh`  | Align ONT `fastq` with `dorado align`. | Dorado (`minimap2`) | `ont-env`
| `scripts/align_contigs_to_ref.sh`  | Wraps `minimap2`, used to align assembled contigs to reference sequence.  | `minimap2` | `ont-env`
#### Alignment Extraction
| Script  | Description | Tool(s) | Environment
| ------------- | ------------- | ---------- | ----- |
| `scripts/extract_split_reads.sh` | Extract split reads and reads providing context in flanking regions by specifying a window size in bp. | `samtools` | `ont-env`
| `scripts/extract_bnd_reads_noWindow.sh` | Extract split reads by specifying chromosomal start and end coordinates, no window needed. | `samtools` | `ont-env`
| `scripts/extract_spanning_contigs.sh` | After aligning assembled contigs to a reference genome with `align_contigs_to_ref.sh`, extract contigs that align to multiple chromosomes. | `samtools` | `ont-env`
#### Assembly
| Script  | Description | Tool(s) | Environment 
| ------------- | ------------- | ------- | ----- |
| `scripts/hifiasm_assembly.sh`  | Assemble a `fastq` using `hifiasm`. | `HiFiasm` | `ont-env`
| `scripts/flye_assembly.sh` | Assemble a `fastq` using `flye`. | `Flye` | `ont-env` 
| `scripts/ragtag_scaffold.sh` | Scaffold conntigs together with RagTag. | `RagTag` | `ont-env`

| Tool  | Description |
| ------------- | ------------- |
| [D-GENIES](https://dgenies.toulouse.inra.fr/run) | UI used for generating dotplots from paired `fasta` |
#### Structural Variant Discovery
| Script  | Description | Tool(s) | Environment 
| ------------- | ------------- | -------- |  ----- |
| `scripts/eaglec_bnds.sh` | Find structural variants from a 3C matrix in `.mcool` format. | `EagleC` | `eaglec`
| `scripts/spectre_cnv.sh` | Calculate & plot copy number information from read depth. | `spectre` | `ont-env`
#### Assembly Annotation
| Script  | Description | Tool(s) | Environment 
| ------------- | ------------- | -------- | ----- |
| `scripts/liftoff_gene_annotations.sh` | USe a reference `.gtf` and `.fasta` to annotate gene sequences in assembly `.fasta` | `Liftoff` | `ont-env`
#### Utilities / Miscellaneous
| Script  | Description | Environment 
| ------------- | ------------- | ----- |
| `scripts/parse_cigar.py` | Parse and plot CIGAR strings within a `sam` file. | `ont-env`
| `scripts/alignment_summarry.sh` | Quickly get alignments of a contig after being aligned to a reference genome. | `ont-env`
| `sctipts/make_bnd_seq.sh`  |  Subsequence 2 sequences from a reference fasta file as given coordinates, returning them as separate `fasta` entries in a single file. | `ont-env`
| `sctipts/make_bnd_seq_concat.sh`  |  Concatenate 2 sequences from a reference fasta file as given coordinates, returning them as a single `fasta` entry. | `ont-env`
| `scripts/gfa_to_fasta.sh` | Convert a `gfa` file to a `fasta` file with `gfatools` | `ont-env`
## Browsers
**[JBrowse2](https://jbrowse.org/jb2/)**
* Upload track files in `data/JBrowse_Sessions`  to view alignments.

## Tool List
All tools below are available as conda environments in `envs/`. \
Specifics of custom parameters can be found in `TOOL-TIPS.md`.
* Seqkit
  * Manipulating sequence files   
  * https://bioinf.shenwei.me/seqkit/
* Quality Control
  * Herro
    * Correct basepair call errors (GPU-enabled)
    * https://github.com/lbcb-sci/herro/tree/main  
  * FiltLong
    * Filter long read `fastq` 
    * https://github.com/rrwick/Filtlong
  * NanoPlot
    * Plot numerous QC metrics for ONT data 
    * https://github.com/wdecoster/NanoPlot
  * Porechop
    * Detect and remove adapter sequences from long reads 
    * https://github.com/rrwick/Porechop
* Alignment
  * Dorado
    * Nanopore suite, including `align` function that uses `minimap2`
    * https://github.com/nanoporetech/dorado
    * `minimap2`
      * Standard aligner for ONT data 
      * https://github.com/lh3/minimap2
* Assembly
  * HiFiasm
    * Haplotype-aware assembler built for HiFi data, but used with `--ont` option 
    * https://hifiasm.readthedocs.io/en/latest/
  * Flye
    * Non-haplotype specific genome assembler  
    * https://github.com/mikolmogorov/Flye
  * RagTag
    * Builds scaffolds from disjoint contigs 
    * https://github.com/malonge/RagTag
* SV Detection
  * EagleC
    * Detect structural variations from a HiC contact matrix 
    * https://github.com/XiaoTaoWang/EagleC
  * Spectre
    * Compute copy number variation from sequencing depth
    * https://github.com/fritzsedlazeck/Spectre
* Genome Annotation       
  * Liftoff
    * Lift over genes from a reference sequence to an assembled / target sequence
    * https://github.com/agshumate/Liftoff 

More tools can be found on [Long-Read-Tools](https://long-read-tools.org/index.html).
