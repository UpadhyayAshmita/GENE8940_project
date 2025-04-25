#!/bin/bash
#SBATCH --job-name=rerun_hifiasm
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=72:00:00
#SBATCH --output=/work/yclab/au08019/GENE8940_project/rerun_hifiasm.log.%j
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

# #Run hifiasm 
# hifiasm -o ${OUT} -t 32 ${READS}

# # first converting the gfa format into fasta format using awk for passing the fasta file to QUAST
# awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa
# # # awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.hap1.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.hap1.fa
# # # awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.hap2.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.hap2.fa

# # # Index the contigs FASTA using samtools
# module load SAMtools/1.16.1-GCC-11.3.0
# samtools faidx $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa
# # Get list of contigs >= 50kb and filtering those from the contigs
# awk '$2 >= 50000' $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa.fai | cut -f1 > $OUTDIR/SuziBlue_Hifiasm.long_contigs.txt
# # Extract only long contigs into a new FASTA
# samtools faidx $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa $(cat $OUTDIR/SuziBlue_Hifiasm.long_contigs.txt) > $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa
# #assembly evaluation using QUAST
# module load QUAST/5.2.0-foss-2022a
# mkdir -p $OUTDIR/QUAST
# quast.py \
# -o $OUTDIR/QUAST \
# -t 32 \
# -r /home/au08019/blueberry_hifi/DraperChrOrdered_modified.fasta \
#  $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa

# #generating mummerplot
# mkdir -p $OUTDIR/mummer
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
# #using mummer for hifi assembly
# nucmer -t 32 /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa -p $OUTDIR/mummer/hifiasmcontigs_vs_ref
# delta-filter -1 $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/hifiasmcontigs_vs_ref.1delta
# mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasmcontigs_vs_ref.1delta -p $OUTDIR/mummer/hifiasmcontigs_vs_ref

# #run busco 
# module load BUSCO/5.8.3-foss-2023a
# mkdir -p $OUTDIR/BUSCO
# busco -i $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa \
#  -o SuziBlue_BUSCO \
#  -m genome \
#  -l eudicots_odb10 \
#  -c 32 \
#  --out_path $OUTDIR/BUSCO

# #running minimap to see how many contigs are overlapping
# #first creating the reference index
# module load minimap2/2.24-GCCcore-11.3.0
# minimap2 -d $OUTDIR/DraperChrOrdered_modified.mmi /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta
# minimap2 $OUTDIR/DraperChrOrdered_modified.mmi $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa > $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf
# head -n 5 $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf
# echo "Number of overlapping alignments:"
# wc -l $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf
# cut -f1 $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf | sort | uniq | wc -l

# #generating bam file for visulation further
# minimap2 -ax asm20 $OUTDIR/DraperChrOrdered_modified.mmi $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa | \
# samtools view -bS - | \
# samtools sort -@ 32 -o $OUTDIR/SuziBlue_Hifiasm_vs_Draper.bam

# #Indexing the BAM file for IGV
# samtools index $OUTDIR/SuziBlue_Hifiasm_vs_Draper.bam

# #downloading the pdf and html file 
# #scp sapelo2:/work/yclab/au08019/GENE8940_project/hifiasm/QUAST/report.pdf .

#tried to check not one to one alignment rather
#delta-filter -r -q $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/hifiasmcontigs_vs_ref.best.delta

#further filtering of contigs file of suziblue for mummerplot 
# show-coords -rcl $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/coords.txt
# awk '$7 >= 10000 && $8 >= 10000 && $9 >= 95' $OUTDIR/mummer/coords.txt > $OUTDIR/mummer/filtered_95percnt_idycord.txt #filtered IDY > 95% only - we have 81,554 in count

# generate filtered delta and cleaner MUMmerplot (IDY ≥ 95%, length ≥ 10kb)
# delta-filter -r -q -i 95 -l 10000 $OUTDIR/mummer/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered.delta

# Create filtered plot (PNG)
# mummerplot --size large --layout --color -f --png $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered.delta -p $OUTDIR/mummer/hifiasmcontigs_vs_ref.filtered


#changing filter of nucmer
# Create output directory for testing
mkdir -p $OUTDIR/mummertest

# Load MUMmer module
module load MUMmer/4.0.0rc1-GCCcore-11.3.0

# Run NUCmer with sensitive parameters
nucmer --maxmatch -l 100 -c 500 -t 32 \
  /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta \
  $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa \
  -p $OUTDIR/mummertest/hifiasmcontigs_vs_ref

# Filter delta file (initial strict filtering for test)
delta-filter -1 $OUTDIR/mummertest/hifiasmcontigs_vs_ref.delta > $OUTDIR/mummertest/hifiasmcontigs_vs_ref.1delta

# Generate plot
mummerplot --size large --layout --color -f --png \
  $OUTDIR/mummertest/hifiasmcontigs_vs_ref.1delta \
  -p $OUTDIR/mummertest/hifiasmcontigs_vs_ref



