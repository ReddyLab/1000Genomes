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

NICE=0
MEMORY=5000 # 5000 or 50000
QUEUE="new,all"
JOB="ACE+"
MAX_PARALLEL=1000
PROGRAM="/home/bmajoros/ACEPLUS/aceplus.pl"
GFF_PROGRAM="/home/bmajoros/ACEPLUS/essex-to-gff-AS2.pl"
THOUSAND="/home/bmajoros/1000G/assembly"
SLURM_DIR=THOUSAND+"/subsets-slurms"
INDIV=THOUSAND+"/combined/HG00096"
SUBSETS=INDIV+"/subsets"
INPUTS=SUBSETS+"/inputs"
OUTPUTS=SUBSETS+"/outputs"
#MODEL="/home/bmajoros/1000G/ACEPLUS/model"
#MODEL="/home/bmajoros/1000G/ACEPLUS/model/aceplus.config"
MODEL="/home/bmajoros/1000G/ACEPLUS/model/shendure.config"

slurm=SlurmWriter()
files=os.listdir(INPUTS)
for file in files:
    if(not rex.find("([^/]+).gff",file)): continue
    filestem=rex[1]
    if(not rex.find("(\d).subset-\d+",filestem)): raise Exception(filestem)
    hap=rex[1]
    refFasta="inputs/"+filestem+".ref.fasta"
    altFasta="inputs/"+filestem+".fasta"
    gff="inputs/"+filestem+".gff"
    essex="outputs/"+filestem+".essex"
    outGFF="outputs/"+filestem+".gff"
    cmd="\ncd "+SUBSETS+"\n\n"+\
        "rm -f "+essex+"\n\n"+\
        PROGRAM+" "+MODEL+" "+refFasta+" "+altFasta+" "+gff+" 0 "+essex+"\n\n"+\
        GFF_PROGRAM+" "+essex+" "+outGFF+" "+hap
    slurm.addCommand(cmd)
slurm.nice(NICE)
slurm.mem(MEMORY)
slurm.setQueue(QUEUE)
slurm.writeArrayScript(SLURM_DIR,JOB,MAX_PARALLEL,
                       "#SBATCH --exclude=x2-01-1,x2-01-2,x2-01-3,x2-01-4,x2-02-1,x2-02-2,x2-02-3,x2-02-4,x2-03-1")

#,"#SBATCH --spread-job\n")

