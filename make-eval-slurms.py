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

THOUSAND="/home/bmajoros/1000G/assembly"
RNA=THOUSAND+"/rna150"
ID_LIST=RNA+"/IDs.txt"
SRC=THOUSAND+"/src"
PROGRAM=SRC+"/eval.py"
SLURM_DIR=THOUSAND+"/eval-slurms"
JOB_NAME="EVAL"
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
        ID=line.rstrip()
        cmd=PROGRAM+" "+ID
        writer.addCommand(cmd)
writer.setQueue("new,all")
writer.nice(NICE)
if(MEMORY): writer.mem(MEMORY)
if(THREADS): writer.threads(THREADS)
writer.writeArrayScript(SLURM_DIR,JOB_NAME,MAX_PARALLEL)



