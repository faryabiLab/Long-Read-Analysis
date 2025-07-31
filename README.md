# Long-Read-Analysis
Scripts, information, and configuration files pertaining to the analysis of Long Reads from Whole Genome Sequencing (WGS), specifically ONT data.

## Environments
Install an environment via `conda env create -f <env file>`
* `ont-env`: Software needed for all ONT data analysis.
* `hic-env`: Software needed for Hi-C/Micro-C analysis.

## Scripts
#### Wrappers
Scripts simply wrapping common operations & logging the command. Run the script with no parameters to see usage.
* `hifiasm_assembly.sh`: Assemble a `fastq` using `hifiasm`
* `align_contigs_to_ref.sh`: Wraps `minimap2`, used to align assembled contigs to reference sequence.

