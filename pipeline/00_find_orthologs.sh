#!/usr/bin/bash

#SBATCH --nodes 1 --ntasks 8 --mem 16G --out logs/findortho.%a.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
if [ -z $SLURM_JOB_ID ]; then
	SLURM_JOB_ID=$$
fi

INDIR=annotation
OUTDIR=results
QUERYPEPS=MAT_locus_peps/mat_locus_query.pep
SAMPLES=strain_pairs.dat
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

module load hmmer/3
module load OrthoFinder
module load ncbi-blast/2.8.1+
module load diamond

IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME PLUS MINUS
do

	mkdir -p $OUTDIR/$NAME
	mkdir -p $OUTDIR/$NAME/FindOrtho
	mkdir -p $OUTDIR/$NAME/MAT_search

	OFILE=$OUTDIR/$NAME/MAT_search/plus_phmmer
	if [ ! -f $OFILE.out ]; then
		phmmer -o $OFILE.out --domtbl $OFILE.domtbl -E 1e-5 --cpu $CPU $QUERYPEPS $INDIR/$PLUS.aa.fasta
	fi
	OFILE=$OUTDIR/$NAME/MAT_search/minus_phmmer
	if [ ! -f $OFILE.out ]; then
		phmmer -o $OFILE.out --domtbl $OFILE.domtbl -E 1e-5 --cpu $CPU $QUERYPEPS $INDIR/$MINUS.aa.fasta
	fi
	if [ ! -e $OUTDIR/$NAME/FindOrtho/$PLUS.aa.fasta ]; then
		rsync -a $INDIR/$PLUS.aa.fasta $OUTDIR/$NAME/FindOrtho
	fi
	if [ ! -e $OUTDIR/$NAME/FindOrtho/$MINUS.aa.fasta ]; then
		rsync -a $INDIR/$MINUS.aa.fasta $OUTDIR/$NAME/FindOrtho
	fi
	# assume 16 threads for now
	orthofinder -M msa -A muscle -a 4 -t 4 -f $OUTDIR/$NAME/FindOrtho
done
