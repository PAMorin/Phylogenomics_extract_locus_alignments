#!/bin/bash

# this is the header for SEDNA
#SBATCH --job-name=Loc_names    ## job name
#SBATCH -e Loc_names_%j.e.txt    ## error message name
#SBATCH -o Loc_names.log.%j.out  ## log file output name
#SBATCH --mail-user=phillip.morin@noaa.gov
#SBATCH --mail-type=ALL  ## (NONE, BEGIN, END, FAIL, ALL)
#SBATCH -p standard
#SBATCH -c 1    ## <number of cores to ask for> (cpu cores per task; max 20/node)
#SBATCH --mem=4G  # only need to use the --mem option when you have a job that requires a lot of memory but not a lot of cores
#SBATCH -t 00:10:00  ## walltime in mins or mins:secs or hrs:mins:secs or days-hours
#  SBATCH --array=1-6  # 1-10 # set to number of fastq files to align 
#  SBATCH -D /scratch/pmorin/temp  ## <folder to change to when starting the job>

##########################################################################################
# Linux command to extract the first line of every file in a directory and output the filename and first line to a text file, formatted with a tab separator


for file in *; do if [ -f "$file" ]; then head -n 1 "$file" | sed "s/^/$file\t/"; fi; done > Locus_names.txt