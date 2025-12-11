#!/bin/env bash
#--------- 

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=repeatmask

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
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=48:00:00

#---------  End Slurm preamble, job commands now follow

# A script for identifying transposable elements in Acartia tonsa genome using the repeat modeler library 
# This script was taken from the Roberts Lab at UW: https://gannet.fish.washington.edu/spartina/paper-gonad-meth/code/
# designed to run on Ubuntu 16.04 LTS with the following software:
# - md5sum
# - RepeatMasker 4.0.7
# - RepBase RepeatMasker Edition 20170127
# - RMBlast with the isb 2.6.0 patch
# - Tandem Repeat Finder v4.09

#Load modules and variables 
#--------------------------------------------------------------------------------

module purge 
module load tetools
#tetools has: BuildDatabase, RepeatModeler, RepeatMasker, runcoseg.pl

# The user needs to set the following three variables.

# Set working directory
wd="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data"

# RepeatMasker program
repeat_masker="RepeatMasker"

# Set CPUs above and here. If not set, will default to 4.
cpus="20"


#Create Dir
#--------------------------------------------------------------------------------

#check and generate, if necessary, folders needed 
cd $wd
if [ ! -d "repeatmasker_output" ]; then
    echo "repeatmasker_output does not exist. Creating now."
    mkdir "repeatmasker_output"
fi

#--------------------------------------------------------------------------------

# Test to see if variables are set
[ -z "${wd}" ] && echo "Working directory not set. Please edit script and set path for wd." && exit 1
[ -z "${repeat_masker}" ] && echo "RepeatMasker path not set. Please edit script and set path for RepeatMasker." && exit 1
[ -z "${cpus}" ] && cpus=4


#Do not need to use this since we made a DeNovo library
# FastA URL
#fasta_url="http://owl.fish.washington.edu/halfshell/genomic-databank/Cvirginica_v300.fa"

#-----------------------------------------------
#denovo library =  consensi_copy.fa.classified 
#check repeat modeler output dir! 
if [ -f "/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database/RM_3318582.TueNov181653002025/consensi_.fa.classified" ]; then
    echo "File exists."
elif [ -f "/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database/RM_3318582.TueNov181653002025/consensi_copy.fa.classified" ]; then
    echo "File exists."
else
    echo "File does not exist."
    #had some issues with making the denovo repeat library.
    #So running repeat classifier manually on existing unclassified library to classify (after round 4 of repeat modeler) 
    cd /gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database/RM_3318582.TueNov181653002025
    apptainer exec $TETOOLS RepeatClassifier -consensi consensi_copy.fa
fi

#explaination of Apptainer: the tetools is a container with some modules unmasked, this does not 
#include RepeatClassifier
#------------------------------------------------
#library file (full path if not in your wd)
#set custom library 
custom_lib="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/database/RM_3318582.TueNov181653002025/consensi_copy.fa.classified"
#set Genome
genome="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/genome_references/acar2_round_2_trimmed.fasta"

#fasta_md5="f9135e323583dc77fc726e9df2677a32"

#ONLY RUN IF NOT DENOVO REPEAT LIBRARY
#-----------------------------------------------------------------------------------------------------------

# Download file to working directory
#wget "${fasta_url}" \
#--directory-prefix="${

# Generate checksum (use ONLY if downloading ref genome from online)
#echo "Generating MD5 checksum..."
#dl_md5=$(md5sum "${wd}"/"${fasta}" | awk '{ print $1 }')
#echo ""
#echo "Checksum: ${dl_md5}"
#echo ""

#Compare cheksums
#echo "Comparing original checksum to downloaded file checksum..."
#echo ""
#diff <(echo "${fasta_md5}") <(echo "${dl_md5}") \
#&& echo "Checksums match!" \
#|| echo "Checksums do not match. Try re-downloading file and then re-running script." exit 1

#-----------------------------------------------------------------------------------------------------------

# Run RepeatMasker
cd "${wd}"

echo ""
echo "Running RepeatMasker. This may take awhile."
echo ""
"${repeat_masker}" \
"${genome}" \
-lib "${custom_lib}" \
-par ${cpus} \
-gff \
-excln \
1> repeatmasker_output/stdout.txt \
2> repeatmasker_output/stderr.txt
echo "All done! Check stderr.txt for any problems."
