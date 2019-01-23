#!/usr/bin/bash
#SBATCH --ntasks 32 -p short --mem 64G --out logs/align_CDS.%a.log
module load t_coffee
module load muscle
module load parallel

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
if [ -z $SLURM_JOB_ID ]; then
	SLURM_JOB_ID=$$
fi

ALNDIR=cds_aln
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
    pushd $ALNDIR/$NAME
#    parallel -j $CPU t_coffee -seq={} -output=fasta_aln -method=cdna_fast_pair ::: *.cds.fa
    parallel -j $CPU muscle -quiet -in {} -out {.}.fasaln ::: *.pep.fa
    # from bioperl
    parallel -j $CPU bp_mrtrans.pl -if fasta -of fasta -i {} -s '{= s:\.pep.fasaln:.cds.fa: =}' -sf fasta -o '{= s:\.pep.fasaln:.cds.mrtrans: =}' ::: *.pep.fasaln
    popd
done
