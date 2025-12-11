#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=wgs_bam

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

#SBATCH -J run_array
#SBATCH -c 1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --array=1-436

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=24:00:00

#---------  End Slurm preamble, job commands now follow

module purge

module load gcc sambamba 

### Processing the alignment files

INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_mappedreads"  # path where the *sam alignments live
param="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/param_sam.txt"

N=$(cat ${param} |  sed '1d' | awk '{print $1}' | sed "${SLURM_ARRAY_TASK_ID}q;d" )  

cd $INPUT

### Convert sam to bam and sort by alignment coordinates

	NAME=${N/.fq.gz.sam/}
	sambamba view -S -t 10 --format=bam ${N} -o ${NAME}.bam
	sambamba sort -t 10 --tmpdir=/users/k/a/kaeller/scratch ${NAME}.bam -o ${NAME}.sorted.bam

### Removing PCR duplicates
for FILE2 in ${NAME}.sorted.bam

do
	NAME2=${NAME/.sorted.bam/}
	sambamba markdup -r -t 10 ${FILE2} ${NAME2}.sorted.rmdup.bam
done


### Indexing for fast lookup

for FILE3 in ${NAME}*.sorted.rmdup.bam
	
do
	sambamba -t 10 index ${FILE3}
done
