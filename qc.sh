#!/bin/bash
#SBATCH --job-name=qc_hifi
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64gb
#SBATCH --time=24:00:00
#SBATCH --output=/work/yclab/au08019/GENE8940_project/qc_hifi.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Define directories
OUTDIR="/work/yclab/au08019/GENE8940_project/qc_hifi"
READS="/home/au08019/blueberry_hifi/Suziblue_allruns.fastq"
mkdir -p $OUTDIR

# Load necessary modules
module load LongQC/1.2.0
module load Jellyfish/2.3.0-GCCcore-11.3.0

# Step 1: Run LongQC for quality assessment
longqc sampleqc -x pb-hifi -o $OUTDIR/longqc_output -t 16 $READS

# Step 2: Count k-mers using Jellyfish
jellyfish count -C -m 21 -s 1G -t 16 -o $OUTDIR/reads.jf $READS

# Step 3: Generate k-mer histogram
jellyfish histo -t 16 $OUTDIR/reads.jf > $OUTDIR/reads.histo

# Step 4: Provide instructions for GenomeScope analysis
echo "K-mer histogram generated at $OUTDIR/reads.histo"
echo "To estimate genome characteristics, upload this histogram to GenomeScope:"
echo "https://genomescope.org/"
echo "Recommended parameters:"
echo "- K-mer length: 21"
echo "- Read length: 20000 (approximate average HiFi read length)"
echo "- Ploidy: 2"
