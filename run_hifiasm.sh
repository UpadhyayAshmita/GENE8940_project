#!/bin/bash
#SBATCH --job-name=run_hifiasm	                                # Job name
#SBATCH --partition=batch		                                # Partition (queue) name
#SBATCH --ntasks=1			                                    # Single task job
#SBATCH --cpus-per-task=6		                                # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=128gb			                                    # Total memory for job
#SBATCH --time=48:00:00  		                                # Time limit hrs:min:sec
#SBATCH --output=/work/yclab/au08019/hifiasm.log.%j	    # Location of standard output and error log files (replace cbergman with your myid)
#SBATCH --mail-user=au08019@uga.edu                            # Where to send mail (replace cbergman with your myid)
#SBATCH --mail-type=END,FAIL                                    # Mail events (BEGIN, END, FAIL, ALL)

# Set the output directory variable
OUTDIR="/work/yclab/au08019/GENE8940_project/hifiasm"
# Create the directory if it does not exist
mkdir -p $OUTDIR
# Load module or conda env
module load hifiasm/0.18.5
# Input and output
READS="Suziblue_allruns.fastq"
OUT="SuziBlue_Hifiasm"

# Run hifiasm
hifiasm -o ${OUT} -t 32 ${READS}
