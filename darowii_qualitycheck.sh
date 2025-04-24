#!/bin/bash
#SBATCH --job-name=darowii_QUAST
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=24:00:00
#SBATCH --output=/work/yclab/au08019/hifiasm.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Output directory
OUTDIR="/work/yclab/au08019/GENE8940_project/darowi"
mkdir -p $OUTDIR

#assembly evaluation using QUAST
module load QUAST/5.2.0-foss-2022a
mkdir -p $OUTDIR/QUAST
quast.py \
-o $OUTDIR/QUAST \
-t 32 \
-r /work/yclab/au08019/GCA_020921065.1_USDA_Vadar_1.0_pri_genomic.fna \
 /work/yclab/au08019/GENE8940_project/rerun_hifiasm/SuziBlue_Hifiasm.contigs.50kb.fa



#downloading the pdf and html file 
#scp sapelo2:/work/yclab/au08019/GENE8940_project/hifiasm/QUAST/report.pdf .

