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

#data exploration 
module load seqkit/2.3.0
seqkit stats /home/au08019/blueberry_hifi/Suziblue_allruns.fastq
#Run hifiasm 
 hifiasm -o ${OUT} -t 32 ${READS}
# # first converting the gfa format into fasta format using awk for passing the fasta file to QUAST
 awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa
#Index the contigs FASTA using samtools
module load SAMtools/1.16.1-GCC-11.3.0
samtools faidx $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa
#Get list of contigs >= 50kb and filtering those from the contigs
awk '$2 >= 50000' $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa.fai | cut -f1 > $OUTDIR/SuziBlue_Hifiasm.long_contigs.txt
#Extract only long contigs into a new FASTA
samtools faidx $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa $(cat $OUTDIR/SuziBlue_Hifiasm.long_contigs.txt) > $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa
#assembly evaluation using QUAST
module load QUAST/5.2.0-foss-2022a
mkdir -p $OUTDIR/QUAST
quast.py \
-o $OUTDIR/QUAST \
-t 32 \
-r /home/au08019/blueberry_hifi/DraperChrOrdered_modified.fasta \
 $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa
#run busco 
module load BUSCO/5.8.3-foss-2023a
mkdir -p $OUTDIR/BUSCO
busco -i $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa \
 -o SuziBlue_BUSCO \
 -m genome \
 -l eudicots_odb10 \
 -c 32 \
 --out_path $OUTDIR/BUSCO

#running minimap to see how many contigs are overlapping
#first creating the reference index
module load minimap2/2.24-GCCcore-11.3.0
minimap2 -d $OUTDIR/DraperChrOrdered_modified.mmi /home/au08019/GENE8940_project/DraperChrOrdered_modified.fasta
minimap2 $OUTDIR/DraperChrOrdered_modified.mmi $OUTDIR/SuziBlue_Hifiasm.contigs.50kb.fa > $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf
head -n 5 $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf
echo "Number of overlapping alignments:"
cut -f1 $OUTDIR/SuziBlue_Hifiasm_vs_Draper.paf | sort | uniq | wc -l #361 overlap contigs were found
# #downloading the pdf and html file 
#scp sapelo2:/work/yclab/au08019/GENE8940_project/rerun_hifiasm/QUAST/report.pdf .
#to request interactive high memory node for debugging
#srun --partition=batch --ntasks=1 --cpus-per-task=32 --mem=164G --time=10:00:00 --pty bash