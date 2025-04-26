#!/bin/bash
#SBATCH --job-name=mummer_per_chr
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64gb
#SBATCH --time=72:00:00
#SBATCH --output=/work/yclab/au08019/GENE8940_project/rerun_hifiasm/mummer_per_chr.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Load MUMmer
module load MUMmer/4.0.0rc1-GCCcore-11.3.0

# Paths
OUTDIR="/work/yclab/au08019/GENE8940_project/rerun_hifiasm"
REF="/home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta"
CONTIGS="$OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa"
CHRS_DIR="$OUTDIR/chromosomes"
MUMMER_OUT="$OUTDIR/mummer_per_chr"

mkdir -p $CHRS_DIR $MUMMER_OUT

# echo "📦 Splitting reference genome by chromosome..."
# cd $CHRS_DIR
# csplit -z -f chr_ -b "%02d.fa" $REF '/^>/' '{*}'

# echo "🔁 Running MUMmerplot chromosome by chromosome..."
# for chr in $CHRS_DIR/chr_*.fa; do
#     chrname=$(basename "$chr" .fa)
#     echo "Processing $chrname..."

#     nucmer -t 16 "$chr" "$CONTIGS" -p $MUMMER_OUT/${chrname}
#     delta-filter -i 95 -l 10000 $MUMMER_OUT/${chrname}.delta > $MUMMER_OUT/${chrname}.filtered.delta
#     mummerplot --size large --layout --color -f --png $MUMMER_OUT/${chrname}.filtered.delta -p $MUMMER_OUT/${chrname}
# done

# echo "✅ All per-chromosome plots generated in: $MUMMER_OUT"

cat $MUMMER_OUT/chr_*.filtered.delta > $MUMMER_OUT/all_chr.filtered.delta
echo "🧹 Running global 1-to-1 best match filter..."
delta-filter -1 $MUMMER_OUT/all_chr.filtered.delta > $MUMMER_OUT/all_chr.best.delta
echo "🖼️ Generating a combined whole-genome plot..."
mummerplot --size large --layout --color -f --svg $MUMMER_OUT/all_chr.best.delta -p $MUMMER_OUT/combined_chr_plot
echo "✅ Finished: Combined clean plot available at: $MUMMER_OUT/combined_chr_plot.svg"
