#!/bin/bash
#SBATCH --job-name=remove_pctN
#SBATCH -e remove_pctN_%j.e.txt    ## error message name
#SBATCH -o remove_pctN.log.%j.out  ## log file output name
#SBATCH --mail-user=phillip.morin@noaa.gov
#SBATCH --mail-type=ALL  ## (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --ntasks-per-node=1
#  SBATCH --cpus-per-task=20
#SBATCH -c 1
#  SBATCH --mem-per-cpu=4G
#SBATCH --time=1:00:00
#SBATCH --output=fasta-processing.%j.out
#########################################################################################

module load tools/rclone/1.59.2

# Set path to directory containing the fasta files
FASTA_DIR=/home/pmorin/projects/Miscellaneous/Delphinidae_UCE/aligned_loci_out6

# Set path to output directory
OUTPUT_DIR=${FASTA_DIR}/loci_high_Ns
lowN_DIR=${FASTA_DIR}/loci_low_Ns

mkdir -p ${OUTPUT_DIR}
mkdir -p $lowN_DIR

pctN=1

# Change to the fasta directory
cd $FASTA_DIR

# Loop through all fasta files in the directory
for FILE in *.fasta
do
    # Get the total length of all sequences in the file
    LENGTH=$(grep -v '>' $FILE | tr -d '\n' | wc -c)
    
    # Get the number of N's in the file
    NUM_NS=$(grep -v '>' $FILE | tr -d '\n' | tr -cd 'Nn' | wc -c)
    
    # Calculate the percentage of N's in the file
    PERCENT_NS=$(echo "scale=4; ($NUM_NS/$LENGTH)*100" | bc)
    
    # If the percentage of N's is greater than pctN, rename the file
    if (( $(echo "$PERCENT_NS > $pctN" | bc -l) )); then
        mv $FILE ${OUTPUT_DIR}/${FILE}
    fi
done


mv $FASTA_DIR/*.fasta $lowN_DIR/

# compress and copy to Google Drive
tar -zcvf Delphinidae_4394UCE_1pctlowN_loci_aligned.tar.gz $lowN_DIR

rclone copy -P Delphinidae_4394UCE_1pctlowN_loci_aligned.tar.gz Gdrive:

