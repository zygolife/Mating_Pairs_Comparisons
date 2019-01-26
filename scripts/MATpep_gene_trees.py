#!/usr/bin/env python3

import csv, os, subprocess
from subprocess import Popen, PIPE, STDOUT

resultdir='results'
matsearch='MAT_search'
gene_trees="gene_trees"
gene_hits_plus = {}
gene_hits_minus = {}

strainpairs = 'strain_pairs.dat'
pepfile = 'peps.aa'
if not os.path.exists(pepfile + ".ssi"):
    subprocess.call(["esl-sfetch","--index","peps.aa"])

with open(strainpairs) as strainpairfh:
    reader = csv.reader(strainpairfh,delimiter=',')
    hdr = reader.next()
    for pair in reader:
        with open(os.path.join(resultdir,pair[0],
                               matsearch,'minus_phmmer.domtbl')) as minus:
            for hit in minus:
                if hit[0] == "#":
                    continue
                hitset = hit.split()
                
                if hitset[3] not in gene_hits_minus:
                    gene_hits_minus[hitset[3]] = {}

                gene_hits_minus[hitset[3]][hitset[0]] = 1

        with open(os.path.join(resultdir,pair[0],matsearch,
                               'plus_phmmer.domtbl')) as plus:
            for hit in plus:
                if hit[0] == "#":
                    continue
                hitset = hit.split()
                
                if hitset[3] not in gene_hits_plus:
                    gene_hits_plus[hitset[3]] = {}

                gene_hits_plus[hitset[3]][hitset[0]] = 1
            
if not os.path.exists(gene_trees):
    os.mkdir(gene_trees)

for gene in gene_hits_minus:
    print(gene)
    with open(os.path.join("gene_trees",gene + ".minus.aa"),"w") as gt:
        for g in gene_hits_minus[gene]:
            subprocess.call(['esl-sfetch',pepfile,g],stdout=gt)

for gene in gene_hits_plus:
    print(gene)
    with open(os.path.join("gene_trees",gene + ".plus.aa"),"w") as gt:
        for g in gene_hits_plus[gene]:
            subprocess.call(['esl-sfetch',pepfile,g],stdout=gt)
            
