Server: `kass`

| Cell line | File type | Description | Path | Associated Script 
| --------- | --------- | ----------- | ---- | ---------------- |
| Granta519 | `.fastq`  | Raw, untrimmed, combined `fastq` | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/raw_fastq20250513_ONT_PBE53188_Granta519_10KB_combined.fastq.gz` | `cat`
| Granta519 | `.fastq`  | Adapter trimmed `fastq` | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/trimmed_fastq/20250513_ONT_PBE53188_Granta519_10KB_combined_trimmed.fastq` | `scripts/porechop_trim.sh` |
| Granta519 | `.fastq`  | Adapter trimmed and 90th percentile by read length filrered | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/trimmed_filter/20250513_ONT_PBE53188_Granta519_10KB_combined_trimmed_filtered.fastq.gz` | `scripts/filter_reads_length.sh`
| Granta519 | `.bam`    | 
