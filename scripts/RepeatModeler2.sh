#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=repeatmodeler2

# Name the output file: Re-direct the log file to your home directory
# The first part of the name (%x) will be whatever you name your job 
#SBATCH -o /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/logs/output_%x_%j.out
#SBATCH -e /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/logs/error_%x_%j.out

# Which partition to use: options include short (<3 hrs), general (<48 hrs), or week
#SBATCH -p general

# Specify when Slurm should send you e-mail.  You may choose from
# BEGIN, END, FAIL to receive mail, or NONE to skip mail entirely.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sstover@uvm.edu

# Run on a single node with four cpus/cores and 8 GB memory
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=48:00:00

#---------  End Slurm preamble, job commands now follow
# Below here, give you bash script with your list of commands

module purge
module load gcc tetools
 
cd /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database

RepeatModeler -database copepod_ref
   -threads 60 -LTRStruct >& run.out &

   #--array 1-1000 
   #length of fasta file  grep ">" copepod_ref | wc -l  <- number of lines with the carrot so / by 1000 to get the chunks 