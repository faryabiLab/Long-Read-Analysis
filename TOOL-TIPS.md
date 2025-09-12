Information and tips concerning the tools used in this repository. \
**All 'included suggested parameters' are included in the master scripts. These are explanations of why they were used.** \
**'Useful parameters' are _not_ in the master scripts, but could be used for testing.**

## NanoPlot
Used for plotting QC metrics for ONT long-read data.
#### Included suggested parameters:
* `--tsv_stats` - Output QC stats as a `.tsv`
* `--raw` - Stores extracted data in a `.tsv`
* `--info_in_report` - Adds the run information to the report.
* `--huge` - Input `fastq` is one large file.

## FiltLong
Used for filtering reads based on their length.
#### Included suggested parameters:
* `--keep_percent x` - Keep the top `x` percent (as an integer) of reads by length. \

There are obviosuly a lot more filtering parameters, but since our mean length < 10Kb, I chose to filter on the distribution.

## Porechop
Automatically determine adapter type and presence, and remove them from read sequence.
#### Useful parameters:
* `--untrimmed` - Bins reads based on adapter presence, but do not actually trim them.

## Dorado
Suite of tools from ONT. It's used here for its `align` submodule.
#### Included suggested parameters:
* `--emit-summary` - Generate alignment statistics and save to summary file.
* `--mm2-opts 'Y'` - The dorado align module uses `minimap2` under the hood, and parameter ensures softclipping is enabled (`-Y`), which is standard for structural variant discovery with long reads.

## Flye
De-novo assembler for long read data. Prodices collapsed assemblies of diploid genomes, represented by a single mosaic haplotype.
#### Included suggested parameters:
* `--nano-hq <fastq>` - Flye gives a couple flags for passing input `fastq` based on the quality of the reads, but for our purposes, the quality is good enough to use this flag.
* `-g <size>` - A rough size of the genome Flye will assemble. This usually helps genome assembly.

## HiFiasm
De-novo assembler for long read data. Produces haplotye-resolved assemblies.
#### Included suggested parameters:
* `--ont` - Specifies input data are ONT R10 reads.

## Spectre
Spectre uses the output from [mosdepth](https://github.com/brentp/mosdepth) to predict copy number values.
#### Included suggested parameters (mosdepth):
* `-x` - Enables 'fast mode', skips mate-pair specific operations.
* `-b 1000` - Window size in base pairs to calculate coverage over.
* `-Q 20` - Minimum quality score for a read to be considered.
