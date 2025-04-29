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
mkdir -p "$OUTDIR"
module load Jellyfish/2.3.1-GCC-12.3.0

# Count k-mers using Jellyfish
jellyfish count -C -m 21 -s 1G -t 16 -o "$OUTDIR/reads.jf" "$READS"

# Generate k-mer histogram
jellyfish histo -t 16 "$OUTDIR/reads.jf" > "$OUTDIR/reads.histo"
echo "K-mer histogram generated at: $OUTDIR/reads.histo"