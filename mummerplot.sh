#!/bin/bash
#SBATCH --job-name=run_mummerplot
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=24:00:00
#SBATCH --output=/work/yclab/au08019/mummerplot.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Output directory
OUTDIR="/work/yclab/au08019/GENE8940_project/hifiasm"
mkdir -p $OUTDIR
# Load module
module load hifiasm/0.24.0-GCCcore-12.3.0 
# Input and output
READS="/home/au08019/GENE8940_project/Suziblue_allruns.fastq"
OUT="${OUTDIR}/SuziBlue_Hifiasm"

#generating mummerplot
mkdir -p $OUTDIR/mummer
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
#using mummer for hifi assembly
nucmer -t 32 /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta $OUTDIR/ragtag/ragtag.scaffold.fasta -p $OUTDIR/mummer/hifiasm_vs_ref
delta-filter -1 $OUTDIR/mummer/hifiasm_vs_ref.delta > $OUTDIR/mummer/hifiasm_vs_ref.1delta
mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasm_vs_ref.1delta -p $OUTDIR/mummer/hifiasm_vs_ref