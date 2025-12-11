#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=wgs_index

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
#SBATCH --array=1-120

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=24:00:00

#---------  End Slurm preamble, job commands now follow

module purge

module load bwa-mem2/2.2.1

echo ${SLURM_ARRAY_TASK_ID}

paramfile=/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_cleanedreads/cleanedreads2/parameter_file.txt
INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_cleanedreads/cleanedreads2"
OUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_mappedreads/"
GENOME="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/genome_references/acar2_round_2_trimmed.fasta"

N=$(cat ${paramfile} |  sed '1d' | awk '{print $1}' | sed "${SLURM_ARRAY_TASK_ID}q;d" )  

# Creating index
#bwa-mem2 index $GENOME

# cd into the directory where the cleaned and trimmed reads live:

cd $INPUT

# Align individual sequences per population to the reference

	IND=${N/_R2.fq.gz/}
	NAME=`basename ${IND}`
	echo "@ Aligning $NAME..."
	bwa-mem2 mem \
	-t 10 \
	-o ${OUT}/${NAME}.sam \
	${GENOME} \
	${N}
