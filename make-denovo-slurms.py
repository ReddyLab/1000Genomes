#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2017 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
import ProgramName
from SlurmWriter import SlurmWriter

EXCLUDE="#SBATCH --exclude=x2-01-1,x2-01-2,x2-01-3,x2-01-4,x2-02-1,x2-02-2,x2-02-3,x2-02-4,x2-03-1\n"
THOUSAND="/home/bmajoros/1000G/assembly"
RNA=THOUSAND+"/rna150"
ID_LIST=RNA+"/IDs.txt"
SRC=THOUSAND+"/src"
PROGRAM=SRC+"/parse-denovo.py"
SLURM_DIR=THOUSAND+"/denovo-slurms"
JOB_NAME="DENOVO"
MAX_PARALLEL=1000
NICE=500
MEMORY=50000
THREADS=0

#=========================================================================
# main()
#=========================================================================

writer=SlurmWriter()
with open(ID_LIST,"rt") as IN:
    for line in IN:
        for hap in (1,2):
            ID=line.rstrip()
            outfile=RNA+"/denovo/"+ID+"."+str(hap)+".denovo"
            cmd=PROGRAM+" "+ID+" "+str(hap)+" > "+outfile
            writer.addCommand(cmd)
writer.setQueue("new,all")
writer.nice(NICE)
if(MEMORY): writer.mem(MEMORY)
if(THREADS): writer.threads(THREADS)
writer.writeArrayScript(SLURM_DIR,JOB_NAME,MAX_PARALLEL,EXCLUDE)



