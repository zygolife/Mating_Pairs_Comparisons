#!/usr/bin/bash

FILE=strain_pairs.dat
LCGFOLDER=/bigdata/stajichlab/shared/projects/ZyGoLife/LCG/Annotation/genomes/
TARGETFOLDER=GENOMES
IFS=,
tail -n +2 $FILE | while read NAME PLUS MINUS
do
	# hardcoded a few things to get the dataset from RefGenome folder
	# /bigdata/stajichlab/shared/projects/ZyGoLife/datasets/genomes/DNA/

	for n in $PLUS $MINUS
	do
		if [ ! -f genomes/$n.fasta ]; then
			ln -s $LCGFOLDER/$n.sorted.fasta $TARGET/$n.fasta
#			ln -s $LCGFOLDER/$n.masked.fasta $TARGET/$n.masked.fasta
		fi
	done
done
