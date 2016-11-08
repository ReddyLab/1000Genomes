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
import os
from Rex import Rex
rex=Rex()
THOUSAND="/home/bmajoros/1000G/assembly"
TPM=THOUSAND+"/tpm.txt"
STRINGTIE_OUT=THOUSAND+"/stringtie.tpm"
SALMON_OUT=THOUSAND+"/salmon.tpm"
KALLISTO_OUT=THOUSAND+"/kallisto.tpm"

def loadTable(filename):
    table=[]
    with open(TPM,"rt") as fh:
        for line in fh:
            fields=line.split()
            (stringtie,salmon,kallisto)=fields
            table.append([float(stringtie),float(salmon),float(kallisto)])
    return table

def countAbove(table,col,threshold):
    count=0
    for row in table:
        if(row[col]>=threshold): count+=1
    return count

#============================== main() ===========================

STRINGTIE_FILE=open(STRINGTIE_OUT,"wt")
SALMON_FILE=open(SALMON_OUT,"wt")
KALLISTO_FILE=open(KALLISTO_OUT,"wt")
table=loadTable(TPM)
for t in range(1,101):
    stringtieCount=countAbove(table,0,t)
    salmonCount=countAbove(table,1,t)
    kallistoCount=countAbove(table,2,t)
    STRINGTIE_FILE.write(str(t)+"\t"+str(stringtieCount)+"\n")
    SALMON_FILE.write(str(t)+"\t"+str(salmonCount)+"\n")
    KALLISTO_FILE.write(str(t)+"\t"+str(kallistoCount)+"\n")
STRINGTIE_FILE.close()
SALMON_FILE.close()
KALLISTO_FILE.close()


