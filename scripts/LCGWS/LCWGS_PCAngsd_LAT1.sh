#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=l12_pcangsd

# Name the output file: Re-direct the log file to your home directory
# The first part of the name (%x) will be whatever you name your job 
#SBATCH --output=/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/logs/%x_%j.out

# Which partition to use: options include short (<3 hrs), general (<48 hrs), or week
#SBATCH --partition=general

# Specify when Slurm should send you e-mail.  You may choose from
# BEGIN, END, FAIL to receive mail, or NONE to skip mail entirely.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kaeller@uvm.edu

# Run on a single node with four cpus/cores and 8 GB memory

#SBATCH -c 1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=24:00:00

#---------  End Slurm preamble, job commands now follow
# load modules

module purge
module load pcangsd/1.36.1

# Give yourself some notes

# Path to your input data (where the beagle file lives)

INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/ANGSD"

# Make directory and set path to save your output (in your repo):

OUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/results/ANGSD/PCA_ADMIX"

SUFFIX="LAT1"

# Make a copy of the list of bam files for all the red + black spruce samples and place in your repo. You'll need this later for making figures.

cp ${INPUT}/${SUFFIX}_bam.list ${OUT}

# Set value of K and number of PCA eigenvalues (=K-1)
# K corresponds to the number of distinct ancestry groups you want to cluster genotypes into

K=2
E=$((K-1))

# Then, run PCA and admixture scores with pcangsd:
# maf = filter: min allele frequency. filters out alleles that are in less than 5% of the population

pcangsd -b ${INPUT}/${SUFFIX}.beagle.gz \
        -o ${OUT}/${SUFFIX}_K${K} \
        -e $E \
        --admix \
        --admix-K $K \
        --maf 0.05 \
        --threads 10 \
        --selection-eig $E \
        --selection \
        --sites-save \
        --maf-save \
        --snp-weights \
        --iter 500