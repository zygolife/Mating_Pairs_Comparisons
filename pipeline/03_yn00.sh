#!/usr/bin/bash
#SBATCH --ntasks 16 -p short --mem 16G --out logs/yn00.%a.log
module load parallel
module load subopt-kaks

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
if [ -z $SLURM_JOB_ID ]; then
	SLURM_JOB_ID=$$
fi

ALNDIR=cds_aln
REPORTS=reports
mkdir -p $REPORTS
SAMPLES=strain_pairs.dat
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME PLUS MINUS
do
    if [ ! -f $REPORTS/$NAME.yn00.tab ]; then
	cp lib/yn00_header $REPORTS/$NAME.yn00.tab
	parallel -j $CPU yn00_cds_prealigned --noheader {} ::: $ALNDIR/$NAME/*.cds.mrtrans >> $REPORTS/$NAME.yn00.tab
    fi
done
