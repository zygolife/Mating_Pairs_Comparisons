#!/usr/bin/bash
#SBATCH -p short --nodes 1 --ntasks 6 --mem 16G --out logs/prep_CDS.log
module load hmmer/3
module load python/3

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
if [ -z $SLURM_JOB_ID ]; then
	SLURM_JOB_ID=$$
fi

SAMPLES=strain_pairs.dat

# run all the steps in parallel - each species name is passed in
# as an argument to the script
tail -n +2 $SAMPLES | cut -d, -f1 | parallel -j $CPU ./scripts/orthologs_to_cdsaln.py {}
