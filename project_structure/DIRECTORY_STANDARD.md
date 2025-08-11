# Directory Standard

Standard directory structure for ONT sequencing analysis of a single cell line or entity. Contains raw and processed data, analysis outputs, and final results.

## Processing flow
```mermaid
flowchart LR
    data_fastq_raw["data/fastq/raw"] --> data_fastq_trimmed["data/fastq/trimmed"]
    data_fastq_trimmed["data/fastq/trimmed"] --> data_fastq_trimmed_filtered["data/fastq/trimmed_filtered"]
    data_fastq_trimmed_filtered["data/fastq/trimmed_filtered"] --> data_fastq_trimmed_filtered_corrected["data/fastq/trimmed_filtered_corrected"]
    data_fastq_raw["data/fastq/raw"] --> data_qc_raw["data/qc/raw"]
    data_fastq_trimmed["data/fastq/trimmed"] --> data_qc_trimmed["data/qc/trimmed"]
    data_fastq_trimmed_filtered["data/fastq/trimmed_filtered"] --> data_qc_trimmed_filtered["data/qc/trimmed_filtered"]
    data_fastq_trimmed_filtered_corrected["data/fastq/trimmed_filtered_corrected"] --> data_qc_trimmed_filtered_corrected["data/qc/trimmed_filtered_corrected"]
    data_align_raw["data/align/raw"] --> data_align_trimmed["data/align/trimmed"]
    data_align_trimmed["data/align/trimmed"] --> data_align_trimmed_filtered["data/align/trimmed_filtered"]
    data_align_trimmed_filtered["data/align/trimmed_filtered"] --> data_align_trimmed_filtered_corrected["data/align/trimmed_filtered_corrected"]
    data_align_trimmed_filtered["data/align/trimmed_filtered"] --> analysis_assembly_assembly_fasta["analysis/assembly/assembly_fasta"]
    data_align_trimmed_filtered_corrected["data/align/trimmed_filtered_corrected"] --> analysis_assembly_assembly_fasta["analysis/assembly/assembly_fasta"]
    data_align_trimmed_filtered["data/align/trimmed_filtered"] --> analysis_copyNumber["analysis/copyNumber"]
    data_align_trimmed_filtered_corrected["data/align/trimmed_filtered_corrected"] --> analysis_copyNumber["analysis/copyNumber"]
    data_align_trimmed_filtered["data/align/trimmed_filtered"] --> analysis_variants["analysis/variants"]
    data_align_trimmed_filtered_corrected["data/align/trimmed_filtered_corrected"] --> analysis_variants["analysis/variants"]
```

## Stages
- **analysis** — Active analysis outputs (genome assembly, CNV, variant calling, etc.)
- **data** — All data files used in the analysis (raw → processed)
- **results** — FINAL output files — static figures and tables for publication or reporting

