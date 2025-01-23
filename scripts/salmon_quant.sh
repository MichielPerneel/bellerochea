#!/bin/bash
#PBS -N salmon_quantification
#PBS -l nodes=1:ppn=16
#PBS -l mem=64gb
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -o data/logs/salmon_quant.log

# Change directory to where the job was submitted from
cd $PBS_O_WORKDIR

# Activate the conda environment
source activate salmon

# Set paths
REF_TRANSCRIPTOME="/data/gent/vo/001/gvo00125/vsc43619/bellerochea/data/GJWO01.fasta.gz"
INDEX_DIR="/data/gent/vo/001/gvo00125/vsc43619/bellerochea/data/salmon_index"
SAMPLES_DIR="/data/gent/vo/001/gvo00125/vsc43619/bellerochea/data/samples"
OUTPUT_DIR="/data/gent/vo/001/gvo00125/vsc43619/bellerochea/data/quantification"
COMBINED_FILE="/data/gent/vo/001/gvo00125/vsc43619/bellerochea/data/bellerochea_quantification.csv"
THREADS=16

# Step 1: Create the Salmon index if not already done
if [ ! -d "$INDEX_DIR" ]; then
    echo "Creating Salmon index..."
    salmon index -t $REF_TRANSCRIPTOME -i $INDEX_DIR --type quasi -p $THREADS
else
    echo "Salmon index already exists, skipping indexing."
fi

# Step 2: Run Salmon quantification for each sample
echo "Starting Salmon quantification..."
mkdir -p $OUTPUT_DIR

for SAMPLE in $SAMPLES_DIR/*_R1.clean.fastq.gz; do
    SAMPLE_NAME=$(basename $SAMPLE _R1.clean.fastq.gz)
    R1=$SAMPLES_DIR/${SAMPLE_NAME}_R1.clean.fastq.gz
    R2=$SAMPLES_DIR/${SAMPLE_NAME}_R2.clean.fastq.gz
    OUTPUT_PATH=$OUTPUT_DIR/${SAMPLE_NAME}_quant
    QUANT_FILE=$OUTPUT_PATH/quant.sf

    if [ -f "$QUANT_FILE" ]; then
        echo "Quantification for sample $SAMPLE_NAME already exists, skipping."
    else
        echo "Processing sample $SAMPLE_NAME..."
        salmon quant -i $INDEX_DIR -l A \
            -1 $R1 -2 $R2 \
            -o $OUTPUT_PATH \
            -p $THREADS \
            --validateMappings
    fi
done

# Step 3: Combine all results into a single CSV file
echo "Combining results into a single CSV file..."
echo "Sample,Name,Length,EffectiveLength,TPM,NumReads" > $COMBINED_FILE

for SAMPLE in $OUTPUT_DIR/*_quant; do
    SAMPLE_NAME=$(basename $SAMPLE _quant)
    QUANT_FILE=$SAMPLE/quant.sf

    if [ -f "$QUANT_FILE" ]; then
        awk -F'\t' -v OFS=',' -v sample="$SAMPLE_NAME" 'NR > 1 {print sample, $1, $2, $3, $4, $5}' $QUANT_FILE >> $COMBINED_FILE
    else
        echo "Warning: Missing quant.sf file for $SAMPLE_NAME, skipping."
    fi
done

echo "All quantification results combined into $COMBINED_FILE."
echo "Salmon quantification completed."