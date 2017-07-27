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
from SlurmWriter import SlurmWriter

THOUSAND="/home/bmajoros/1000G/assembly"
SRC=THOUSAND+"/src"
DEDUP=SRC+"/deduplicate-gff.py"
UNIQ=SRC+"/aceplus-uniq-IDs.py"
GEUVADIS=THOUSAND+"/geuvadis.txt"
SLURM_DIR=THOUSAND+"/dedup-gff-slurms"
JOB_NAME="DEDUP"
MAX_PARALLEL=1000
NICE=500
MEMORY=50000
THREADS=None
PREDICTORS=("logreg","MC","shendure","splice-only","arab")

def getDirs():
    dirs=[]
    with open(GEUVADIS,"rt") as IN:
        for line in IN:
            id=line.rstrip()
            dir=THOUSAND+"/combined/"+id
            dirs.append(dir)
    return dirs

#=========================================================================
# main()
#=========================================================================

dirs=getDirs()
writer=SlurmWriter()
for dir in dirs:
    for allele in range(1,3):
        A=str(allele)
        GFFs=""
        for predictor in PREDICTORS:
            GFFs+=A+"."+predictor+".gff "
        cmd="cd "+dir+"\n"
        #cmd+="cat "+GFFs+" | grep ALT > tmp."+A+"\n"
        cmd+=UNIQ+" "+GFFs+" | grep ALT > tmp."+A+"\n"
        cmd+=DEDUP+" tmp."+A+" > "+A+".tmp.alt ; rm tmp."+A+"\n"
        cmd+="cat "+A+".aceplus.gff | grep -v ALT > "+A+".tmp.ref\n"
        cmd+="rm -f all-predictors.gff tmp.alt tmp.ref\n"
        cmd+="cat "+A+".tmp.ref "+A+".tmp.alt > "+A+".all-predictors.gff\n"
        cmd+="rm "+A+".tmp.ref "+A+".tmp.alt\n"
        cmd+="echo \\[done\\]\n"
        writer.addCommand(cmd)
writer.setQueue("new,all")
writer.nice(NICE)
if(MEMORY): writer.mem(MEMORY)
if(THREADS): writer.threads(THREADS)
writer.writeArrayScript(SLURM_DIR,JOB_NAME,MAX_PARALLEL,
                        "#SBATCH --exclude=x2-01-1,x2-01-2,x2-01-3,x2-01-4,x2-02-1,x2-02-2,x2-02-3,x2-02-4,x2-03-1\n")


