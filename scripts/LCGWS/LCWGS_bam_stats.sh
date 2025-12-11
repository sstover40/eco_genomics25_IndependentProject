#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=wgs_bamstats

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

# Remove all software modules and load all and only those needed

module purge
module load gcc samtools

TRIREPO="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods"
INPUT="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/LCWGS_mappedreads"

    #param="/gpfs1/cl/ecogen/pbio6800/GroupProjects/tripods/data/param_sam.txt"

    #N=$(cat ${param} |  sed '1d' | awk '{print $1}' | sed "${SLURM_ARRAY_TASK_ID}q;d" )  

### Make the header for your pop's stats file

echo -e "SampleID Num_reads Num_R1 Num_R2 Num_Paired Num_MateMapped Num_Singletons Num_MateMappedDiffChr Coverage_depth" \
  >${TRIREPO}/results/LCWGS_bamstats.txt

### Calculate stats on bwa alignments

for FILE in ${INPUT}/*.sorted.rmdup.bam  # loop through each of your pop's processed bam files in the input directory
do
	F=${FILE/.sorted.rmdup.bam/} # isolate the sample ID name by stripping off the file extension
	NAME=`basename ${F}`  # further isolate the sample ID name by stripping off the path location at the beginning
	echo ${NAME} >> ${TRIREPO}/results/all.names  # print the sample ID names to a file
	samtools flagstat ${FILE} | awk 'NR>=9&&NR<=15 {print $1}' | column -x  # calculate the mapping stats
done >> ${TRIREPO}/results/all.flagstats  # append the stats as a new line to an output file that increases with each iteration of the loop


### Calculate mean sequencing depth of coverage


for FILE2 in ${INPUT}/*.sorted.rmdup.bam
do
	samtools depth ${FILE2} | awk '{sum+=$3} END {print sum/NR}'  # calculate the per-site read depth, sum across sites, and calc the mean by dividing by the total # sites
done >> ${TRIREPO}/results/all.coverage # append the mean depth as a new line to an output file that increases with each iteration of the loop


### Put all the stats together into 1 file:

paste ${TRIREPO}/results/all.names \
	${TRIREPO}/results/all.flagstats \
	${TRIREPO}/results/all.coverage \
	>>${TRIREPO}/results/all.stats.txt # stitch ('paste') the files together column-wise
