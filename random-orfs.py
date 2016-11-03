#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2016 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
from FastaReader import FastaReader
import random

NUM_ORFS=10000
DATA="/data/reddylab/Reference_Data/Genomes/hg19"
filename=DATA+"/chr1.fa"

stops={"TAG":True, "TGA":True, "TAA":True}

def sample(chr):
    L=len(chr)
    pos=int(random.uniform(0,L-100000))
    while(pos<L-3):
        codon=chr[pos:pos+3]
        if(codon=="ATG"): break
        pos+=3
    if(codon!="ATG"): return -1
    codons=0
    while(pos<L-3):
        codon=chr[pos:pos+3]
        if(codon[0]=='N' or codon[1]=='N' or codon[2]=='N'): return -1
        if(stops.get(codon,False)): break
        codons+=1
        pos+=3
    return codons

#============================ main() ==============================
reader=FastaReader(filename)
while(True):
    [defline,seq]=reader.nextSequence()
    if(not defline): break
    for i in range(NUM_ORFS):
        length=sample(seq)
        if(length<0): continue
        print(length,flush=True)
reader.close()



