#!/bin/bash
#SBATCH --job-name=run_hifiasm
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128gb
#SBATCH --time=48:00:00
#SBATCH --output=/work/yclab/au08019/hifiasm.log.%j
#SBATCH --mail-user=au08019@uga.edu
#SBATCH --mail-type=END,FAIL

# Output directory
OUTDIR="/work/yclab/au08019/GENE8940_project/hifiasm"
mkdir -p $OUTDIR

# Load module
module load hifiasm/0.19.6-GCCcore-11.3.0

# Input and output
READS="${OUTDIR}/Suziblue_allruns.fastq"
OUT="${OUTDIR}/SuziBlue_Hifiasm"

# Run hifiasm 
hifiasm -o ${OUT} -t 32 ${READS}
