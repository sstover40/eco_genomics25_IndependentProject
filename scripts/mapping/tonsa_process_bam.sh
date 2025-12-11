#!/bin/bash

# Clear module environment and load processing software
module purge
module load gcc sambamba
module load gcc bedtools2

# Define paths
SAM="/users/a/j/ajones76/projects/eco_genomics_2025/final_project/trinity_to_genome.sam"
BASENAME=$(basename "$SAM" .sam)
OUTDIR="/users/a/j/ajones76/projects/eco_genomics_2025/final_project"
SCRATCH="/users/a/j/ajones76/scratch"

cd $OUTDIR

# Convert .sam to .bam
sambamba view -S -t 10 --format=bam "$SAM" -o "${BASENAME}.bam"

# Sort .bam by alignment coordinates
sambamba sort -t 10 --tmpdir="$SCRATCH" "${BASENAME}.bam" -o "${BASENAME}.sorted.bam"

# Index the .bam
sambamba index -t 10 "${BASENAME}.sorted.bam"

# Convert the sorted .bam to .bed
bedtools bamtobed -i trinity_to_genome.sorted.bam > trinity_to_genome.bed