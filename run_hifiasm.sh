#!/bin/bash
#SBATCH --job-name=run_hifiasm
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=24:00:00
#SBATCH --output=/work/yclab/au08019/hifiasm.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Output directory
OUTDIR="/work/yclab/au08019/GENE8940_project/hifiasm"
mkdir -p $OUTDIR
# Load module
module load hifiasm/0.24.0-GCCcore-12.3.0 
# Input and output
READS="/home/au08019/blueberry_hifi/Suziblue_allruns.fastq"
OUT="${OUTDIR}/SuziBlue_Hifiasm"

# Run hifiasm 
hifiasm -o ${OUT} -t 32 ${READS}
#first converting the gfa format into fasta format using awk for passing the fasta file to QUAST
#awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.bp.p_ctg.fa
awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.hap1.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.hap1.fa
awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.hap2.p_ctg.gfa > $OUTDIR/SuziBlue_Hifiasm.hap2.fa

# Extract unitigs (primary unitigs in GFA format) from HiFiAsm output
awk '/^S/{print ">"$2"\n"$3}' $OUTDIR/SuziBlue_Hifiasm.bp.r_utg.gfa > $OUTDIR/SuziBlue_Hifiasm.unitigs.fa

#using ragtag for scaffolding
module load RagTag/2.0.1-foss-2022a
mkdir -p $OUTDIR/ragtag

ragtag.py scaffold \
  -t 32 \
  -o $OUTDIR/ragtag \
  /home/au08019/blueberry_hifi/DraperChrOrdered_modified.fasta \
  $OUTDIR/SuziBlue_Hifiasm.unitigs.fa

#checking the stats of ragtag using seqkit to see the num of seq
module load SeqKit/2.5.1
seqkit stats ragtag.scaffold.fasta

#assembly evaluation using QUAST
module load QUAST/5.2.0-foss-2022a
mkdir -p $OUTDIR/QUAST
quast.py \
-o $OUTDIR/QUAST \
-t 32 \
-r /home/au08019/blueberry_hifi/DraperChrOrdered_modified.fasta \
 $OUTDIR/ragtag/ragtag.scaffold.fasta 

#downloading the pdf and html file 
#scp sapelo2:/work/yclab/au08019/GENE8940_project/hifiasm/QUAST/report.pdf .

