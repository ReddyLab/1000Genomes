#!/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2016 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
from SlurmWriter import SlurmWriter
import os

BASE="/home/bmajoros/hapmix"
CHROMS=range(1,23)
slurmDir=BASE+"/slurm"
jobName="HAPMIX"
maxParallel=100

writer=SlurmWriter()
for chr in CHROMS:
    parfile="chr"+str(chr)+".par"
    cmd="cd /home/bmajoros/hapmix; perl bin/runHapmix.pl "+parfile
    writer.addCommand(cmd)
writer.mem(5000)
writer.setQueue("new,all")
writer.writeArrayScript(slurmDir,jobName,maxParallel)

