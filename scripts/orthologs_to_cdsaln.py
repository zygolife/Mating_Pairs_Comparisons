#!/usr/bin/env python3

from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
from Bio import SeqIO
import csv,re,os,subprocess, sys

from subprocess import Popen, PIPE, STDOUT
from multiprocessing.dummy import Pool as ThreadPool

sfetch = "esl-sfetch"

prefix = "Absidia_caerulea"

if len(sys.argv) > 1:
    prefix = sys.argv[1]

print("Processing strain pair %s" %(prefix))

dbfile = "db/cds.fa"
outdir = "cds_aln/%s" % (prefix)
infile = "results/%s/FindOrtho/Orthogroups.csv" % (prefix)

if not os.path.exists(outdir):
    os.mkdir(outdir)

Orthogroups = {}

Hdr = []
with open(infile,"r") as infh:
    rdr = csv.reader(infh,delimiter="\t")
    hdr = next(rdr)

    colcount = len(hdr)
    for n in range(1,len(hdr)):
        Hdr.append(re.sub(r'\.aa','',hdr[n]))
        
    for row in rdr:

        Orthogroups[row[0]] = []
        for col in row[1:]:
            Orthogroups[row[0]].append(col.split(", "))

count=0
for og in Orthogroups:
    if len(Orthogroups[og][0]) + len(Orthogroups[og][1]) == 2:
#        print(og, Orthogroups[og])
        outfile = os.path.join(outdir,og + ".cds.fa")
        outfilepep = os.path.join(outdir,og + ".pep.fa")
        if os.path.exists(outfile):
            continue
        names = []
        for nm in Orthogroups[og]:
            names.append(nm[0])
        nameslst = "\n".join(names)

        p = subprocess.Popen([sfetch,"-o", outfile,
                              "-f",dbfile,"-"],stdin=PIPE,close_fds=True)
        p.communicate(input=nameslst.encode())

        peps = []
        
        for cds in SeqIO.parse( outfile, "fasta"): 
            cdsseq = cds.seq
            lensq = len(cdsseq)
            v = lensq % 3
            
            if v != 0:                
                cdsseq = cdsseq[0:lensq-v]
                
            peps.append(SeqRecord(seq = cdsseq.translate(to_stop=True),
                                  id = cds.id, 
                                  description = cds.description))

        SeqIO.write(peps,outfilepep,"fasta")
        count=count+1
        
        

