#!/bin/bash
#SBATCH --job-name=extract_seqs     ## job name
#SBATCH -e extract_seqs_%j.e.txt    ## error message name
#SBATCH -o extract_seqs.log.%j.out  ## log file output name
#SBATCH --mail-user=phillip.morin@noaa.gov
#SBATCH --mail-type=ALL  ## (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --job-name=extract_seqs
#SBATCH -p medmem
#SBATCH -c 1
#SBATCH --array=1-84%20 # %# limits the number of subjobs in an array that run concurrently, e.g., array 1-10, with 2 jobs at a time, would be --array=1-10%2.
#  SBATCH --mem=4G
#SBATCH -t 8:00:00   ## walltime in mins or mins:secs or hrs:mins:secs. 
#SBATCH -D /scratch/pmorin/temp ## <folder to change to when starting the job>

####################################################################################

# Load necessary modules
module load bio/bedtools/2.31.1
module load bio/samtools/1.19
module load bio/htslib/1.19
# module load tools/pigz/2.4

# Define input and output directories and files
THREADS=5
FASTADIR=/home/pmorin/NGS_data_files/Delphinidae_phylo/Consensus_wo_iupac
UCEDIR=/home/pmorin/projects/Miscellaneous/Delphinidae_UCE
BEDFILE=$UCEDIR/UCE_Oorc_GCA_937001465.bed2_padded.txt
OUTPUTDIR=$UCEDIR/UCE_loci_out_stringent

# 83 Delphinidae consensus sequences
FASTAFILES=(
Ccom_SRR12437578_angsd_consensus_genome.fa.gz
Ccom_z480_angsd_consensus_genome.fa.gz
Ceut_z2317_angsd_consensus_genome.fa.gz
Chea_z7320_angsd_consensus_genome.fa.gz
Chec_z3746_angsd_consensus_genome.fa.gz
Dcap_z173977_angsd_consensus_genome.fa.gz
Ddel_ERR11040185_angsd_consensus_genome.fa.gz
Ddel_SRR14018397_angsd_consensus_genome.fa.gz
Ddel_SRR14018398_angsd_consensus_genome.fa.gz
Ddel_SRR22515609_angsd_consensus_genome.fa.gz
Ddel_z145475_angsd_consensus_genome.fa.gz
Ddel_z4525_angsd_consensus_genome.fa.gz
Dleu_z67934_angsd_consensus_genome.fa.gz
Fatt_z123337_angsd_consensus_genome.fa.gz
Fatt_z173621_angsd_consensus_genome.fa.gz
Ggri_DRR307688_angsd_consensus_genome.fa.gz
Ggri_SRR13362265_angsd_consensus_genome.fa.gz
Ggri_SRR14018395_angsd_consensus_genome.fa.gz
Ggri_z178265_angsd_consensus_genome.fa.gz
Gmac_z112653_angsd_consensus_genome.fa.gz
Gmac_z112731_angsd_consensus_genome.fa.gz
Gmac_z17981_angsd_consensus_genome.fa.gz
Gmel_ERR11837528_angsd_consensus_genome.fa.gz
Gmel_SRR11097123_angsd_consensus_genome.fa.gz
Gmel_z8324_angsd_consensus_genome.fa.gz
Lacu_SRR16086814_angsd_consensus_genome.fa.gz
Lacu_z7822_angsd_consensus_genome.fa.gz
Lalb_USNM594176_angsd_consensus_genome.fa.gz
Laus_CNR0454788_angsd_consensus_genome.fa.gz
Lbor_z145224_angsd_consensus_genome.fa.gz
Lcru_KS20-20LC_angsd_consensus_genome.fa.gz
Lhos_z30468_angsd_consensus_genome.fa.gz
Lobl_DRR394914_angsd_consensus_genome.fa.gz
Lobl_DRR394915_angsd_consensus_genome.fa.gz
Lobl_SRR8616940_angsd_consensus_genome.fa.gz
Lobl_z93893_angsd_consensus_genome.fa.gz
Lobs_z37793_angsd_consensus_genome.fa.gz
Lper_z2316_angsd_consensus_genome.fa.gz
Mmon_SRR14571305_angsd_consensus_genome.fa.gz
Nasi_SRR21047154_angsd_consensus_genome.fa.gz
Nasi_SRR6923833_angsd_consensus_genome.fa.gz
Obre_z23971_angsd_consensus_genome.fa.gz
Ohei_z2907_angsd_consensus_genome.fa.gz
Oorc_Morgan_angsd_consensus_genome.fa.gz
Oorc_SRR8616848_angsd_consensus_genome.fa.gz
Oorc_z0020235_angsd_consensus_genome.fa.gz
Pcra_z18462_angsd_consensus_genome.fa.gz
Pcra_z27510_angsd_consensus_genome.fa.gz
Pcra_z45928_angsd_consensus_genome.fa.gz
Pele_SRR11097149_angsd_consensus_genome.fa.gz
Pele_SRR17730108_angsd_consensus_genome.fa.gz
Pele_SRR17730109_angsd_consensus_genome.fa.gz
Pele_SRR17730110_angsd_consensus_genome.fa.gz
Pele_z185378_angsd_consensus_genome.fa.gz
Psin_SRR15435903_angsd_consensus_genome.fa.gz
Psin_z0186934_angsd_consensus_genome.fa.gz
Satt_SRR16086851_angsd_consensus_genome.fa.gz
Satt_z11377_angsd_consensus_genome.fa.gz
Satt_z66915_angsd_consensus_genome.fa.gz
Sbre_SRR13167959_angsd_consensus_genome.fa.gz
Sbre_z139066_angsd_consensus_genome.fa.gz
Schi_SRR7662931_angsd_consensus_genome.fa.gz
Schi_z61912_angsd_consensus_genome.fa.gz
Scly_SRR16086849_angsd_consensus_genome.fa.gz
Scly_z4185_angsd_consensus_genome.fa.gz
Scoe_SRR14018392_angsd_consensus_genome.fa.gz
Scoe_SRR14018400_angsd_consensus_genome.fa.gz
Scoe_z145384_angsd_consensus_genome.fa.gz
Sflu_z455_angsd_consensus_genome.fa.gz
Sfro_SRR16086847_angsd_consensus_genome.fa.gz
Sfro_z4538_angsd_consensus_genome.fa.gz
Slon_SRR16086845_angsd_consensus_genome.fa.gz
Slon_z1746_angsd_consensus_genome.fa.gz
Slon_z38195_angsd_consensus_genome.fa.gz
Slon_z67092_angsd_consensus_genome.fa.gz
Tadu_SRR5357656_angsd_consensus_genome.fa.gz
Tadu_SRR8616894_angsd_consensus_genome.fa.gz
Tadu_z157446_angsd_consensus_genome.fa.gz
Tere_SAMN06114300_angsd_consensus_genome.fa.gz
Ttru_SRR14668014_angsd_consensus_genome.fa.gz
Ttru_SRR8282859_angsd_consensus_genome.fa.gz
Ttru_SRR8616895_angsd_consensus_genome.fa.gz
Ttru_SRR940825_angsd_consensus_genome.fa.gz
Ttru_SRX200685_angsd_consensus_genome.fa.gz
)

mkdir -p $OUTPUTDIR

cd $FASTADIR

# Extract sequence based on array index
FASTA=${FASTAFILES[$SLURM_ARRAY_TASK_ID-1]}

FA=`echo $FASTA | cut -f1 -d "."` # fasta file name before ".fa.gz"
SP=`echo $FASTA | cut -f1 -d "_"`
SPID=`echo $FASTA | cut -f1,2 -d "_"`

echo "indexing $FASTA..."
# 
# # unzip fasta files # this shouldn't be necessary with bedtools 2.31.1 (fixed issue)
# # gunzip $FASTADIR/$FASTA
# 
# index fasta files
# samtools faidx $FASTADIR/$FA.fa.gz

echo "Extracting sequences from $FASTA..."

# Use bedtools to extract sequences from fasta file based on bed file coordinates
bedtools getfasta -fi $FASTADIR/$FA.fa.gz -bed $BEDFILE -fo $OUTPUTDIR/${FA%.fa}.bedout2.fa -name+
# -name+ adds information from additional columns to the fasta headers

# add species name to each fasta header
sed -E "s/^>/>${SPID}_/g" $OUTPUTDIR/${FA%.fa}.bedout2.fa > $OUTPUTDIR/${FA%.fa}.bedout.fa

# rm $OUTPUTDIR/${FA%.fa}.bedout2.fa # for some reason this causes some to fail, so leave off of script and remove manually

