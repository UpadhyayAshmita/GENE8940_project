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

#generating mummerplot
mkdir -p $OUTDIR/mummer
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
#using mummer for hifi assembly
nucmer -t 32 /work/yclab/au08019/GCA_020921065.1_USDA_Vadar_1.0_pri_genomic.fna /work/yclab/au08019/GENE8940_project/rerun_hifiasm/SuziBlue_Hifiasm.contigs.50kb.fa -p $OUTDIR/mummer/hifiasm_vs_darowi
delta-filter -1 $OUTDIR/mummer/hifiasm_vs_darowi.delta > $OUTDIR/mummer/hifiasm_vs_darowi.1delta
mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasm_vs_darowi.1delta -p $OUTDIR/mummer/hifiasm_vs_darowi