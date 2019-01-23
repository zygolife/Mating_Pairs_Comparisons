#!/usr/bin/bash

FILE=strain_pairs.dat
LCGFOLDER=/bigdata/stajichlab/shared/projects/ZyGoLife/LCG/Annotation/annotate
TARGETFOLDER=annotation

mkdir -p $TARGETFOLDER
IFS=,
tail -n +2 $FILE | while read NAME PLUS MINUS
do
	# hardcoded a few things to get the dataset from RefGenome folder
	# /bigdata/stajichlab/shared/projects/ZyGoLife/datasets/genomes/DNA/

	for n in $PLUS $MINUS
	do
		if [ ! -f $TARGETFOLDER/$n.CDS.fasta ]; then
			ln -s $LCGFOLDER/$n/predict_results/*.transcripts.fa $TARGETFOLDER/$n.CDS.fasta
			ln -s $LCGFOLDER/$n/predict_results/*.proteins.fa $TARGETFOLDER/$n.aa.fasta
			ln -s $LCGFOLDER/$n/predict_results/*.gff3 $TARGETFOLDER/$n.gff3
		fi
	done
done
