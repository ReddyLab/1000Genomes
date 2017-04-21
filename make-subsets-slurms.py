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
import os
from SlurmWriter import SlurmWriter
from Rex import Rex
rex=Rex()

NICE=500
MEMORY=5000
QUEUE="new,all"
JOB="ACE+"
MAX_PARALLEL=1000
PROGRAM="/home/bmajoros/ACEPLUS/aceplus.pl"
THOUSAND="/home/bmajoros/1000G/assembly"
SLURM_DIR=THOUSAND+"/subsets-slurms"
INDIV=THOUSAND+"/combined/HG00096"
SUBSETS=INDIV+"/subsets"
INPUTS=SUBSETS+"/inputs"
OUTPUTS=SUBSETS+"/outputs"
MODEL="/home/bmajoros/1000G/ACEPLUS/model"

slurm=SlurmWriter()
files=os.listdir(INPUTS)
for file in files:
    if(not rex.find("([^/]+).gff",file)): continue
    filestem=rex[1]
    refFasta="inputs/"+filestem+".ref.fasta"
    altFasta="inputs/"+filestem+".fasta"
    gff="inputs/"+filestem+".gff"
    outfile="outputs/"+filestem+".essex"
    cmd="\ncd "+SUBSETS+"\n\n"+\
        "rm -f "+outfile+"\n\n"+\
        PROGRAM+"  "+MODEL+"  "+refFasta+"  "+altFasta+"  "+gff+"  0  "+outfile
    slurm.addCommand(cmd)
slurm.nice(NICE)
slurm.mem(MEMORY)
slurm.setQueue(QUEUE)
slurm.writeArrayScript(SLURM_DIR,JOB,MAX_PARALLEL)

