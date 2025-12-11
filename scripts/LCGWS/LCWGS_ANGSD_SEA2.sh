#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=wgs_angsd_s2

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
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=48:00:00

#---------  End Slurm preamble, job commands now follow

### load modules

module purge

module load gcc/13.3.0-xp3epyt angsd/0.935-4asngpy pcangsd/1.36.1 bwa-mem2/2.2.1

### Set up directories and variables

#mkdir /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/ANGSD

INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_mappedreads"

OUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/ANGSD"

REF="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/genome_references/acar2_index/acar2_round_2_trimmed.fasta"

### Need something here for multiple population inputs: ie, POP1, POP2

cd /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/genome_references

#PARAM1="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/sea_samp_GW.txt"
PARAM2="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/sea_samp_RW.txt"

#POP1=$(cat ${PARAM1} |  sed '1d' | sed 's|["]||g' | awk '{print $2}' )
POP2=$(cat ${PARAM2} |  sed '1d' | sed 's|["]||g' | awk '{print $2}' )

### Suffix will be either LAT (latitudinal) or SEA (seasonal)
SUFFIX="SEA2"  # Optional suffix for naming outputs to distinguish analyses

#for i in ${POP1}
#do
#    ls ${INPUT}/${i}.R2.sorted.rmdup.bam >>${OUT}/${SUFFIX}_bam.list
#done

for j in ${POP2}
do
    ls ${INPUT}/${j}.R2.sorted.rmdup.bam >>${OUT}/${SUFFIX}_bam.list
done

###########################################
#  Estimating Genotype Likelihoods (GLs)  #
###########################################

angsd -b ${OUT}/${SUFFIX}_bam.list \
-ref ${REF} \
-anc ${REF} \
-out ${OUT}/${SUFFIX} \
-nThreads 20 \
-remove_bads 1 \
-C 50 \
-baq 1 \
-minMapQ 20 \
-minQ 20 \
-GL 2 \
-doSaf 1 \
-doCounts 1 \
-minInd 4 \
-setMinDepthInd 1 \
-setMaxDepthInd 40 \
-setMinDepth 10 \
-skipTriallelic 1 \
-doMajorMinor 4 \
-doMaf 2 \
-SNP_pval 1e-6 \
-minMaf 0.01 \
-doGLF 2