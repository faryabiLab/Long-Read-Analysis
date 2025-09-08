Server: `kass`

| Cell line | File type | Description | Path | Associated Script 
| --------- | --------- | ----------- | ---- | ---------------- |
| Granta519 | `.fastq`  | Raw, untrimmed, combined `fastq` | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/raw_fastq20250513_ONT_PBE53188_Granta519_10KB_combined.fastq.gz` | `cat`
| Granta519 | `.fastq`  | Adapter trimmed `fastq` | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/trimmed_fastq/20250513_ONT_PBE53188_Granta519_10KB_combined_trimmed.fastq` | `scripts/porechop_trim.sh` |
| Granta519 | `.fastq`  | Adapter trimmed and 90th percentile by read length filrered | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/trimmed_filter/20250513_ONT_PBE53188_Granta519_10KB_combined_trimmed_filtered.fastq.gz` | `scripts/filter_reads_length.sh`
| Granta519 | `.bam`    | hg38-aligned adapter trimmed ONT reads | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/trimmed_align/Granta519_ONT_10KB_porechop_withRG_correctSeqNames.bam` | `scripts/align_ont_dorado.sh` |  
| Granta519 | `.bed.gz` | hg38 per-base alignment depth | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/20250513_ONT_PBE53188_Granta519_10KB_analysis/CNV` | `scripts/spectre_cnv.sh` |
| Granta519 | `.fasta` | Haplotype-aware genome-wide assembly | `/dobby/noah/ONT-data/20250513_ONT_PBE53188_Granta519_10KB/20250513_ONT_PBE53188_Granta519_10KB_analysis/global_assembly/HiFiasm/trimmed/*.fasta` | `scripts/hifiasm_assembly.sh` |

