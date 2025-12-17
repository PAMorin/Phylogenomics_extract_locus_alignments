#!/bin/bash

#SBATCH --job-name=Loc_names    ## job name
#SBATCH -e Loc_names_%j.e.txt    ## error message name
#SBATCH -o Loc_names.log.%j.out  ## log file output name
#SBATCH -c 1 
#SBATCH --mem=4G  
#SBATCH -t 00:10:00  ## walltime in mins or mins:secs or hrs:mins:secs or days-hours

##########################################################################################
# Linux command to extract the first line of every file in a directory and output the filename and first line to a text file, formatted with a tab separator


for file in *; do if [ -f "$file" ]; then head -n 1 "$file" | sed "s/^/$file\t/"; fi; done > Locus_names.txt