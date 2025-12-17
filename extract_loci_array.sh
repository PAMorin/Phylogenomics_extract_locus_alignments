#!/bin/bash
#SBATCH --job-name=extract_seqs     ## job name
#SBATCH -e extract_seqs_%j.e.txt    ## error message name
#SBATCH -o extract_seqs.log.%j.out  ## log file output name
#SBATCH -p standard
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH --array=1-39 # %# limits the number of subjobs in an array that run concurrently, e.g., array 1-10, with 2 jobs at a time, would be --array=1-10%2.
#SBATCH -t 8:00:00   ## walltime in mins or mins:secs or hrs:mins:secs. 

####################################################################################

# Load necessary modules
module load bio/bedtools/2.31.1
module load bio/samtools/1.19
module load bio/htslib/1.19

set -eux # halt if error, missing value; print commands first prints the command to the terminal, using a + to indicate that the output is a command

#### --- User-defined variables ---
# Define input and output directories and files
THREADS=5
INDIR=/home/pmorin/projects/Miscellaneous/mysticete_phylo/bam_files
FASTADIR=$INDIR/Consensus_wo_iupac
BEDFILE=$INDIR/Egla_GCA_028564815.1_Busco_200-15k_bed.txt
OUTPUTDIR=$INDIR/loci_out

# Consensus sequences
FASTAFILES=(
B.a.acu_ERR11040176_angsd_consensus_genome.fa.gz
B.a.sca_30011_angsd_consensus_genome.fa.gz
B.b.acu_DRR014695_angsd_consensus_genome.fa.gz
B.b.bor_123379_angsd_consensus_genome.fa.gz
B.b.bor_ERR13248974_angsd_consensus_genome.fa.gz
B.b.bor_SRR26062094_angsd_consensus_genome.fa.gz
B.bon_SRR4011113_angsd_consensus_genome.fa.gz
B.e.bry_15034_angsd_consensus_genome.fa.gz
B.e.bry_26365_angsd_consensus_genome.fa.gz
B.e.bry_9880_angsd_consensus_genome.fa.gz
B.e.bry_SRR27003634_angsd_consensus_genome.fa.gz
B.e.ede_17381_angsd_consensus_genome.fa.gz
B.e.ede_5313_angsd_consensus_genome.fa.gz
B.m.bre_157407_angsd_consensus_genome.fa.gz
B.m.bre_BmuANT13947_angsd_consensus_genome.fa.gz
B.m.bre_BmuIO5026_angsd_consensus_genome.fa.gz
B.m.mus_BmuCH056_angsd_consensus_genome.fa.gz
B.m.mus_SRR14467046_angsd_consensus_genome.fa.gz
B.m.mus_SRR25748633_angsd_consensus_genome.fa.gz
B.m.mus_SRR5665644_angsd_consensus_genome.fa.gz
B.mys_SRR34419942_angsd_consensus_genome.fa.gz
B.omu_157395_angsd_consensus_genome.fa.gz
B.p.phy_SRR25114418_angsd_consensus_genome.fa.gz
B.p.vel_SRR23615136_angsd_consensus_genome.fa.gz
B.ric_SRR10331559_angsd_consensus_genome.fa.gz
C.mar_5989_angsd_consensus_genome.fa.gz
C.mar_ERR6460101_angsd_consensus_genome.fa.gz
D.del_145475_angsd_consensus_genome.fa.gz
E.aus_SRR29386327_angsd_consensus_genome.fa.gz
E.aus_SRR29386330_angsd_consensus_genome.fa.gz
E.gla_28311_angsd_consensus_genome.fa.gz
E.jap_43856_angsd_consensus_genome.fa.gz
E.rob_SRR12437599_angsd_consensus_genome.fa.gz
K.sim_10122_angsd_consensus_genome.fa.gz
M.mon_8308_angsd_consensus_genome.fa.gz
M.n.kuz_145207_angsd_consensus_genome.fa.gz
M.n.nov_SRR5665639_angsd_consensus_genome.fa.gz
P.bla_7360_angsd_consensus_genome.fa.gz
P.sin_SRR15435906_angsd_consensus_genome.fa.gz)

####--- end User-defined variables ---

mkdir -p $OUTPUTDIR

cd $FASTADIR

# Extract FASTA file based on array index
FASTA=${FASTAFILES[$SLURM_ARRAY_TASK_ID-1]}

FA=`echo $FASTA | cut -f1,2,3,4 -d "_"` # fasta file name before ".fa.gz"
SP=`echo $FASTA | cut -f1 -d "_"`
SPID=`echo $FASTA | cut -f1,2 -d "_"`
echo $FA
echo $SP
echo $SPID

echo "Extracting sequences from $FASTA..."

# Use bedtools to extract sequences from fasta file based on bed file coordinates
bedtools getfasta -fi $FASTADIR/${FA}_genome.fa.gz -bed $BEDFILE -fo $OUTPUTDIR/${FA%.fa}.bedout2.fa -name+
# -name+ adds information from additional columns to the fasta headers

# add species name and sample ID to each fasta header
sed -E "s/^>/>${SPID}_/g" $OUTPUTDIR/${FA%.fa}.bedout2.fa > $OUTPUTDIR/${FA%.fa}.bedout.fa

rm $OUTPUTDIR/${FA%.fa}.bedout2.fa # for some reason this causes some to fail, so leave off of script and remove manually

