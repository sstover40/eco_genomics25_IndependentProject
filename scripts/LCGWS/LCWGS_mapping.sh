#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=wgs_mapping

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

cd /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_index

module purge

module load bwa-mem2/2.2.1

# Define the path to and name of the indexed reference genome
GENOME="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/genome_references/acar2_round_2_trimmed.fasta"

# Creating index
bwa-mem2 index $GENOME

# Shortcut to index

#INDEX="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_index.bwt.2bit.64"

# Define the input directory with your *cleaned* fastq files

INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_cleanedreads"

# Define your output directory where the mapping files will be saved

OUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_mappedreads/"

# cd into the directory where the cleaned and trimmed reads live:

cd $INPUT

# Align individual sequences per population to the reference

for READ2 in *R2.fq.gz
do
	IND=${READ2/_R2.fq.gz/}
	NAME=`basename ${IND}`
	echo "@ Aligning $NAME..."
	bwa-mem2 mem \
	-t 10 \
	-o ${OUT}/${NAME}.sam \
	${GENOME} \
	${READ2}
done



