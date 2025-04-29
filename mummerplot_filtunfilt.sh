#!/bin/bash
#SBATCH --job-name=mummerplot_vis
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=72:00:00
#SBATCH --output=/work/yclab/au08019/GENE8940_project/mummerplot_vis.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Output directory
OUTDIR="/work/yclab/au08019/GENE8940_project/rerun_hifiasm"
mkdir -p $OUTDIR
# Load module
module load hifiasm/0.24.0-GCCcore-12.3.0 
# Input and output
READS="/home/au08019/blueberry_hifi/Suziblue_allruns.fastq"
OUT="${OUTDIR}/SuziBlue_Hifiasm"
#generating mummerplot
mkdir -p $OUTDIR/mummer
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
using mummer for hifi assembly
nucmer -t 32 /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa -p $OUTDIR/mummer/hifiasmcontigs_vs_ref
delta-filter -1 $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/hifiasmcontigs_vs_ref.1delta
mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasmcontigs_vs_ref.1delta -p $OUTDIR/mummer/hifiasmcontigs_vs_ref
#further filtering of contigs file of suziblue for mummerplot based on manual filtering
show-coords -rcl $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/coords.txt
awk '$7 >= 10000 && $8 >= 10000 && $9 >= 95' $OUTDIR/mummer/coords.txt > $OUTDIR/mummer/filtered_95percnt_idycord.txt #filtered IDY > 95% only - we have 81,554 in count
#generate filtered delta and cleaner MUMmerplot (IDY ≥ 95%, length ≥ 10kb)
delta-filter -r -q -i 95 -l 10000 $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered.delta
#Create filtered plot (PNG)
mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered.delta -p $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered