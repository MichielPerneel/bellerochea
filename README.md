# Quantifying Bellerochea abundance and activity in the BPNS

## Bioinformatics steps
1. Index the Bellerochea transcriptome with Salmon
The transcriptome was downloaded from https://www.ebi.ac.uk/ena/browser/view/GJWO01000000.

2. Run Salmon quantification on the PE RNA-seq data
For this, we'll use the preprocessed reads that are in the `data/` directory. The reads have been trimmed and quality filtered.
The combined csv file 'data/quantification_combined.csv' will look like this:

| **Sample** | **Name** | **Length** | **EffectiveLength** | **TPM** | **NumReads** |
|------------|----------|------------|---------------------|---------|--------------|
| 10_21_330  | ENA\|GJWO01000001\|GJWO01000001.1 | 112 | 936.384  | 10 | 100 |
| 10_21_330  | ENA\|GJWO01000001\|GJWO01000002.1 | 1126 | 935.384 | 20 | 200 |
| 10_21_330  | ENA\|GJWO01000001\|GJWO01000003.1 | 830 | 693.384  | 30 | 300 |
| 10_21_700  | ENA\|GJWO01000001\|GJWO01000001.1 | 1127 | 936.384 | 40 | 400 |
| ...        | ... | ...        | ...                  | ...      | ...    |

The sample names are the same as the ones covered in the samples.xlsx metadata. They can now be combined and analyzed.

