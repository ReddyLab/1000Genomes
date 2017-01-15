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
import sys
import os
import glob
from Rex import Rex
rex=Rex()

if(len(sys.argv)!=2):
    exit(sys.argv[0]+" <dir>")
directory=sys.argv[1]

files=glob.glob(directory+"/*.fast?")
for file in files:
    with open("tmp.fastb","wt") as OUT:
        with open(file,"rt") as IN:
            for line in IN:
                if(rex.find(">\S+",line)):
                    OUT.write(">dna\n")
                else: OUT.write(line)
    os.system("mv tmp.fastb "+file)


