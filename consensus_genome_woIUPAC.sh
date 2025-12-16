#!/bin/bash

#SBATCH --job-name=consensus_genome   ## job name
#SBATCH -e consensus_genome%j.e.txt    ## error message name
#SBATCH -o consensus_genome.log.%j.out  ## log file output name
#SBATCH -p standard
#SBATCH -c 5    ## <number of cores to ask for> (cpu cores per task?)
#SBATCH --mem=20G # max memory on regular nodes = 96G; himem = 1.5TB
#SBATCH --array=1-2 # -81%30 
#SBATCH -t 96:00:00   ## walltime in mins or mins:secs or hrs:mins:secs. 

##########################################################################################
# Uses Angsd to extract consensus genome from bam file

module load bio/angsd/0.933

set -eux

#### --- User-defined variables ---

REFDIR=/home/pmorin/Ref_genomes/Egla/GCA_028564815.1_mEubGla1_pri
REF=GCA_028564815.1_mEubGla1.hap2_genomic.fna

# input and output directories
INDIR=/home/pmorin/projects/Miscellaneous/mysticete_phylo/bam_files # input directory
CONS_DIR=${INDIR}/Consensus_wo_iupac # output directory
TEMP=${CONS_DIR}/TEMP
mkdir -p ${CONS_DIR}
mkdir -p ${TEMP}
baseQ=30
mapQ=25

# list of bam file base names (format = species_sample)
BAMLIST=(
B.a.acu_ERR11040176
B.b.bor_123379
)

#### --- End user-defined variables ---

# cd ${CONS_DIR}

# generate windows list for each scaffold
BAMDIR=${BAMLIST[$SLURM_ARRAY_TASK_ID-1]} # if using an alias list within the script
echo ${BAMDIR}

# BAMDIR=`echo $BAM | cut -f5 -d "/"`
SP=`echo $BAMDIR | cut -f1 -d "_"`
sample=`echo $BAMDIR | cut -f2 -d "_"`
BAMFILE=${INDIR}/${BAMDIR}_dedup.bam
echo ${BAMFILE}

# Define input and output file names for ANGSD
OUT_PREFIX=${SP}_${sample}_angsd_consensus_genome

#########
# Create consensus genome

angsd -i $BAMFILE -ref ${REFDIR}/${REF} -out ${CONS_DIR}/$OUT_PREFIX -minQ $baseQ -minMapQ $mapQ -doMajorMinor 1 -doMaf 1 -doCounts 1 -GL 1 -doFasta 2 -doDepth 1

mv ${CONS_DIR}/${OUT_PREFIX}.arg ${TEMP}
mv ${CONS_DIR}/${OUT_PREFIX}.mafs.gz ${TEMP}
mv ${CONS_DIR}/${OUT_PREFIX}.depthSample ${TEMP}
mv ${CONS_DIR}/${OUT_PREFIX}.depthGlobal ${TEMP}
rm -r ${TEMP}

# Print job completion time
date

# -doFasta 2   use the most common base. In the case of ties a random base is chosen among the bases with the same maximum counts. N's or filtered based are ignored. The "-doCounts 1" options for allele counts is needed in order to determine the most common base. If multiple individuals are used the four bases are counted across individuals.