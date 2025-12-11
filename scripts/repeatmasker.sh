#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=repeat_masker

# Name the output file: Re-direct the log file to your home directory
# The first part of the name (%x) will be whatever you name your job 
#SBATCH --output=/users/a/j/ajones76/projects/eco_genomics_2025/final_project/mylogs/%x_%j.out

# Which partition to use: options include short (<3 hrs), general (<48 hrs), or week
#SBATCH --partition=general

# Specify when Slurm should send you e-mail.  You may choose from
# BEGIN, END, FAIL to receive mail, or NONE to skip mail entirely.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ajones76@uvm.edu

# Run on a single node with four cpus/cores and 8 GB memory
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=48:00:00

#---------  End Slurm preamble, job commands now follow

# Clear module environment and load mapping software
module purge
module load gcc tetools

cd /users/a/j/ajones76/projects/eco_genomics_2025/final_project/mydata/RepeatMasker

RepeatMasker -pa 36 -gff -lib Dfam-RepeatMasker.lib acar2_round_2_trimmed.fasta
