#!/bin/bash

#a script for creating a repeat library in the Acartia tonsa (coepepod) genome in order to ID transposable elements 
#repeat modeler will make a DE-NOVO library of Transposable elements throughout the A. Tonsa reference genome.
#using 3 denovo repeat finding programs: 
# 1. RECON 
# 2. RepeatScout 
# 3. LtrHarvest/Ltr_retriever

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
#SBATCH --cpus-per-task=60
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=48:00:00

#---------  End Slurm preamble, job commands now follow
# Below here, give you bash script with your list of commands

#load modules 
module purge
module load gcc tetools

#prevent RMBlast from sending out Blast data reports via internet (increases time) 
#export BLAST_USAGE_REPORT=false
 
cd /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database

#original run script
RepeatModeler -database copepod_ref -threads 60 -LTRStruct >& run.out

#referenceing a half finished run - can pick it up from there since it took so long
#RepeatModeler -database copepod_ref -threads 60 -recoverDir RM_3318582.TueNov181653002025

